#!/usr/bin/env python3
"""
SSH (TCP/22) Host Discovery and Reconnaissance Script
Scans 10.0.0.0/24 for hosts listening on TCP/22, attempts OS detection, and
collects hostname/OS information for each host found.
"""

import socket
import subprocess
import re
from datetime import datetime
from typing import Dict, List, Optional, Tuple

class SSHFinder:
    """SSH host discovery and OS/fingerprint analysis."""

    def __init__(self):
        self.results: Dict[str, dict] = {}

    def probe_host(self, ip: str, port: int = 22) -> Optional[dict]:
        """Probe a single IP for TCP/22 response using nmap."""
        result = {
            "ip": ip,
            "timestamp": datetime.now().isoformat(),
            "ssh_open": False,
            "nmap_output": "",
            "hostname": None,
            "os_info": None,
            "version": None,
            "service_info": None,
        }

        try:
            output = subprocess.run(
                ["nmap", "-sT",  # TCP syn scan
                 "-p", str(port),  # TCP/22 only
                 "-A",            # aggressive options
                 "-O",            # OS detection
                 "-sV",           # version detection
                 "--open",        # report only open ports
                 ip],
                capture_output=True,
                text=True,
                timeout=30,
                cwd="/home/tkjode/.hermes/cache/scratch"
            )
            result["nmap_output"] = output.stdout
            result["nmap_exit_code"] = output.returncode

            # Check if SSH port 22 is open
            if "PORT 22/tcp   open" in output.stdout or "22/tcp  open" in output.stdout or "ssh" in output.stdout.lower():
                result["ssh_open"] = True
                result["found"] = True

            return result
        except subprocess.TimeoutExpired:
            result["error"] = "Timeout (30s)"
            return result
        except FileNotFoundError:
            result["error"] = "nmap not found"
            return result
        except Exception as e:
            result["error"] = str(e)
            return result

    def parse_nmap_output(self, output: str, ip: str) -> dict:
        """Parse nmap output for host details."""
        details = {
            "hostname": None,
            "os_info": None,
            "version": None,
            "service": None,
            "service_version": None,
            "device_type": None,
            "os_matched": None,
            "os_confidence": None,
        }

        lines = output.strip().split('\n')

        # Host report section
        host_match = re.search(r"Nmap scan report for ([^,]+), ([^ ]+) (\d+\.%d\.%d)(?:\.%d)?", output) or \
                     re.search(r"Nmap scan report for ([^,]+)\(([\w.]+)\)", output) or \
                     re.search(r"Nmap scan report for ([^,]+): (\d+\.%d\.%d)", output)
        if host_match:
            details["hostname"] = host_match.group(1).strip()
            details["ip"] = host_match.group(2)
            details["raw_ip"] = host_match.group(1)

        # Port / service section
        for line in lines:
            line_stripped = line.strip()

            # Service name line: "SSH (SSHv2.8)" etc.
            if "=ssh=" in line_stripped.lower():
                details["service"] = "ssh"
                service_match = re.search(r'(\w+)', line_stripped)
                if service_match:
                    svc = service_match.group(1)
                    details["service_version"] = svc if svc else None

            # Version line
            if re.search(r'version:', line_stripped, re.IGNORECASE):
                ver_match = re.search(r'version:\s*([^\s\[\n]+)', line_stripped)
                if ver_match:
                    details["version"] = ver_match.group(1).strip()

            # Device type flag
            if re.search(r'Device type:\s+', line_stripped):
                dmatch = re.search(r'Device type:\s+(\S+)', line_stripped)
                if dmatch:
                    details["device_type"] = dmatch.group(1).strip()

            # Hostname (Nmap DNS)
            if re.search(r'Nmap hostname:', line_stripped):
                hmatch = re.search(r"Nmap hostname:\s*(\S+)", line_stripped)
                if hmatch:
                    details["hostname"] = hmatch.group(1).strip()

            # Service Info: hostname
            if re.search(r'Service Info:\s+Hostname:', line_stripped):
                hmatch = re.search(r'Hostname:\s*(\S+)', line_stripped)
                if hmatch:
                    details["hostname"] = hmatch.group(1).strip()

            # Service Info: OS
            if re.search(r'Service Info:\s+OS:', line_stripped):
                omatch = re.search(r'OS:\s*(.+)/\S+.*$', line_stripped)
                if omatch:
                    details["os_info"] = omatch.group(1).strip()

            # Device fingerprint
            if re.search(r'Device fingerprint:\s+', line_stripped):
                fmatch = re.search(r'Device fingerprint:\s+(\S+)', line_stripped)
                if fmatch:
                    details["device_type"] = fmatch.group(1).strip()

            # OpenSSH version
            if re.search(r'OpenSSH', line_stripped):
                vmatch = re.search(r'OpenSSH\s([\d\.]+)', line_stripped)
                if vmatch:
                    details["version"] = vmatch.group(1).strip()

            # Linux open port
            if 'Linux' in line_stripped and 'Linux open ports:' in line_stripped:
                details["os_info"] = "Linux"

        return details

    def resolve_hostname(self, ip: str) -> Optional[str]:
        """Try to resolve the IP to a DNS name."""
        try:
            # Reverse DNS lookup
            addr = socket.inet_aton(ip)
            reverse = socket.gethostbyaddr(addr)[0]
            return reverse
        except socket.herror:
            return None
        except Exception:
            return None

    def try_ssh_banner(self, ip: str, port: int = 22) -> Optional[str]:
        """Attempt an SSH banner grab (non-interactive)."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3)
            sock.connect((ip, port))
            banner = sock.recv(1024).decode()[:500]
            sock.close()
            return banner if banner else None
        except:
            return None

    def generate_report(self) -> str:
        """Generate the final markdown report."""
        lines = [
            "# Local Network SSH (TCP/22) Scan Report",
            "",
            f"**Scan Target:** 10.0.0.0/24",
            f"**Scan Time:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} UTC",
            "",
            "---",
            "",
        ]

        # Run scan on the entire subnet
        hosts_found = 0
        for host_ip in range(1, 255):
            ip_addr = f"10.0.0.{host_ip:03d}"
            result = self.probe_host(ip_addr)

            if result and result.get("found", False):
                self.results[ip_addr] = result
                hosts_found += 1

        # Add reverse DNS lookups for all found hosts
        for ip, result in self.results.items():
            rdns = self.resolve_hostname(ip)
            if rdns:
                result["hostname"] = rdns

        if not self.results:
            lines.extend([
                "## Results",
                "",
                "No hosts listening on TCP/22 were found.",
                "",
                "If you know there should be SSH servers on this network, try:",
                "",
                "- Increasing the scan timeout per host",
                "- Expanding the subnet range (e.g. 10.0.0.0/8)",
                "- Checking if the network requires different IP addressing",
            ])
            lines.append("")
            lines.append("```")
            lines.append(self.results)
            lines.append("```\n")
            return "\n".join(lines)

        # Build per-host report sections
        for ip in sorted(self.results.keys()):
            result = self.results[ip]
            hostname = result.get("hostname", ip.split('.')[3])
            ssh_open = result["ssh_open"]

            lines.extend([
                f"## {hostname} ({ip})",
                f"",
                f"**SSH Open:** {ssh_open}",
            ])

            if result.get("found"):
                lines.extend([
                    "",
                    "---",
                    "",
                    "### Scan Details",
                    "",
                ])

                nmap_out = result.get("nmap_output", "")
                if nmap_out:
                    # Truncate very long output
                    if len(nmap_out) > 3000:
                        nmap_out = nmap_out[:3000] + "\n... (output truncated, see full output below)"
                    lines.append("```\n" + nmap_out + "\n```")

                details = self.parse_nmap_output(result["nmap_output"], ip)
                if details.get("version"):
                    lines.append(f"*Service:* {details['service']}")
                    lines.append(f"*Version:* {details['version']}")
                if details.get("os_info"):
                    lines.append(f"**OS:** {details['os_info']}")
                if details.get("device_type"):
                    lines.append(f"*Device Fingerprint:* {details['device_type']}")
                if details.get("hostname"):
                    lines.append(f"*Nmap DNS:* {details['hostname']}")
                if details.get("service_info"):
                    lines.append(f"*Service Info:* {details['service_info']}")

                lines.append("")
                lines.append("---")

        lines.extend([
            "",
            "---",
            "",
            "## Summary",
            "",
            f"Total hosts with TCP/22 open: **{hosts_found}**",
            "",
        ])

        return "\n".join(lines)


def main():
    print("=" * 80)
    print("SSH Host Discovery Report")
    print(f"  Target: 10.0.0.0/24")
    print(f"  Time:   {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print("=" * 80)
    print()

    finder = SSHFinder()
    report = finder.generate_report()
    print(report)

    # Save full report
    with open("/home/tkjode/Dev/homelab/ssh_scan_report.md", "w") as f:
        f.write(report)
    print(f"\nFull report saved to: /home/tkjode/Dev/homelab/ssh_scan_report.md")


if __name__ == "__main__":
    main()
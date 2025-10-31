# Mailcheck

Mailcheck is a powerful email service configuration checker tool that helps system administrators and IT professionals verify and troubleshoot email service configurations for Office 365 and Google Workspace.

## Features

- **DNS Record Verification**
  - MX Records check
  - NS Records validation
  - SPF Record verification

- **Office 365 Specific Checks**
  - MX record validation for Office 365
  - Autodiscover CNAME verification
  - Microsoft TXT record verification

- **Google Workspace Specific Checks**
  - MX record validation for Google Workspace
  - Google site verification TXT record check

## Requirements

- Bash shell
- `dig` command (DNS lookup utility)
- Zenity (for GUI interface)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/1985epma/mailcheck.git
```

2. Make the script executable:
```bash
chmod +x mailcheck.sh
```

## Usage

Simply run the script:

```bash
./mailcheck.sh
```

The tool will open a graphical interface where you can enter your domain name and perform various checks.

## Output

The tool provides detailed information about:
- DNS configuration
- Email service provider detection
- Service-specific configuration validation
- Potential configuration issues

## License

See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

- [1985epma](https://github.com/1985epma)
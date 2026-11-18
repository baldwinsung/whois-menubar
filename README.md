# SimpleWhoisGeo (archived)

> **Archived 2026-11-18.** Replaced by the `ip_info` tool in
> [online-presence](https://github.com/baldwinsung/online-presence): the same
> holder, country and abuse/NOC/tech contacts, from RDAP, for up to 20 IPs at
> once, as an MCP tool or from the command line:
> `onlinepresence 8.8.8.8 1.1.1.1`
> To remove the app:
> `curl -fsSLO https://raw.githubusercontent.com/baldwinsung/homebrew-tap/main/uninstall-menubar-apps.sh && bash uninstall-menubar-apps.sh whois`

A macOS menu bar app for bulk WHOIS lookups on IP addresses.

> ⚠️ **Disclaimer:** This software is provided "as is", without warranty of any kind. The author(s) are not liable for any damages or issues arising from the use of this software. Use at your own risk. See [LICENSE](LICENSE) for full details.

> 🤖 **AI Disclosure:** This project was created with assistance from [Claude](https://claude.ai) by Anthropic.

## Features

- Bulk lookup: enter a comma- or newline-separated list of IP addresses
- Results table showing IP · Provider/Org · Country for each address
- Click any result row to see Abuse, NOC, and Tech contacts (email and phone, both clickable)
- Concurrent lookups with a 10-second timeout per IP
- Deduplicates input IPs automatically
- Lives in your menu bar — no Dock icon, no window clutter

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9+ / Xcode command-line tools (`xcode-select --install`)
- `/usr/bin/whois` (ships with macOS — no extra install needed)
- No external package dependencies

## Build & Install

### Quick (recommended)

```bash
./install.sh
```

This builds a release binary, assembles `SimpleWhoisGeo.app`, and launches it. The app appears in your menu bar immediately.

### Manual

```bash
swift build -c release
```

The compiled binary is placed under `.build/release/`. To run it directly:

```bash
.build/release/SimpleWhoisGeo
```

To build and install as a proper `.app` bundle (named `SimpleWhoisGeo.app`), use `install.sh`.

## Usage

1. Click the `⋯` icon in your menu bar to open the lookup window.
2. Enter one or more IP addresses, separated by commas or newlines.
3. Click **Lookup**.
4. Results appear in a table: **IP · Provider/Org · Country**.
5. Click any row to open a popover showing Abuse, NOC, and Tech contact details.
   - Email addresses and phone numbers are clickable links.
6. Use the **Help** and **Quit** buttons in the footer (visible after the first lookup).

> **Note:** Private/internal IP ranges ([RFC 1918](https://www.rfc-editor.org/rfc/rfc1918)) — `10.0.0.0/8`, `172.16.0.0/12`, and `192.168.0.0/16` — will not return meaningful WHOIS results. These addresses are not routable on the public internet and have no public registration records.

## License

MIT. See [LICENSE](LICENSE) if present, or use freely.

## Contributing

Bug reports and pull requests are welcome. The codebase is intentionally small — keep it that way.

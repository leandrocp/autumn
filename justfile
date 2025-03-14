#!/usr/bin/env just --justfile

# List all available commands
default:
    @just --list

# Update CSS files from Autumnus repository
update-css:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "⚠️  This will update all css files in priv/static/css/"
    echo ""
    read -p "Are you sure you want to proceed? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi

    rm -rf priv/static/css/*.css

    mkdir -p priv/static/css
    curl -s https://api.github.com/repos/leandrocp/autumnus/contents/css | \
      grep "\"name\":.*\\.css\"" | \
      cut -d'"' -f4 | \
      while read -r file; do
        echo "Downloading $file"
        curl -s -o "priv/static/css/$file" "https://raw.githubusercontent.com/leandrocp/autumnus/main/css/$file"
      done

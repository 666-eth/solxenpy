import requests
import os
import subprocess
import sys

def download_file(url, filename):
    """Download file from a URL and save it locally"""
    r = requests.get(url)
    with open(filename, 'wb') as f:
        f.write(r.content)

def create_or_verify_wallet():
    """Create a new Solana wallet or verify existing wallet's balance"""
    keypair_path = '/root/.config/solana/id.json'
    min_balance = 1.0  # Minimum balance in SOL required to skip creating a new wallet

def run_command(command):
    """Run a command through subprocess and print the output."""
    print("Running command:", ' '.join(command))
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        print("Error:", result.stderr)
        raise subprocess.CalledProcessError(result.returncode, command)
    print("Output:", result.stdout)
    return result.stdout


def setup_solana_client(eth_address, keypair_path):
    project_dir = 'solana_rust_client'
    if os.path.exists(project_dir):
        subprocess.run(["rm", "-rf", project_dir], check=True)
    os.makedirs(project_dir)
    os.chdir(project_dir)  # Change into the project directory

    subprocess.run(["cargo", "init", "--bin"], check=True)
    update_cargo_toml()  # Ensure this runs in the project directory
    download_and_prepare_rust_source()  # This is called after initializing the Rust project
    subprocess.run(["cargo", "build"], check=True)  # Build the project

    # Configure Solana CLI
    subprocess.run(["solana", "config", "set", "--url", "https://api.devnet.solana.com"], check=True)
    subprocess.run(["solana", "config", "set", "--keypair", keypair_path], check=True)

    # Execute the program in a loop
    while True:
        subprocess.run(["./target/debug/solana_rust_client", "--fee", "5000", "--address", eth_address], check=True)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 script.py <Ethereum Address>")
        sys.exit(1)
    eth_address = sys.argv[1]
    keypair_path = create_or_verify_wallet()
    setup_solana_client(eth_address, keypair_path)

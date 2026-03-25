import subprocess
import sys
import argparse
from colorama import init, Fore, Style

init(autoreset=True)

COLORS = {
    'system': Fore.YELLOW,
    'global': Fore.BLUE,
    'local':  Fore.GREEN,
}


def is_git_repository():
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--is-inside-work-tree'],
            capture_output=True, text=True, check=True)
        return result.stdout.strip() == 'true'
    except subprocess.CalledProcessError:
        return False


def run_git_config(args):
    result = subprocess.run(['git', 'config'] + args, capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout:
        return {}
    config = {}
    for line in result.stdout.strip().split('\n'):
        key, value = line.split('=', 1)
        config[key] = value
    return config


def print_config(config, title, color):
    print(f'{color}{title} Configuration:{Style.RESET_ALL}')
    if config:
        for key, value in sorted(config.items()):
            print(f'    {key} = {value}')
    else:
        print(f'    (empty)')
    print()


def main():
    parser = argparse.ArgumentParser(
        description='Display Git configurations with override detection')
    parser.add_argument('--override', action='store_true',
                        help='Run even if not inside a Git repository')
    args = parser.parse_args()

    if not args.override and not is_git_repository():
        print("Not inside a Git repository. Use --override to run anyway.")
        sys.exit(1)

    system    = run_git_config(['--system', '-l'])
    my_global = run_git_config(['--global', '-l'])
    local     = run_git_config(['--local',  '-l'])

    print_config(system,    'System', COLORS['system'])
    print_config(my_global, 'Global', COLORS['global'])
    print_config(local,     'Local',  COLORS['local'])

    # Effective config: local beats global beats system
    effective = {}
    for scope, config in [('system', system), ('global', my_global), ('local', local)]:
        for k, v in config.items():
            effective[k] = (v, scope)

    print(f'{Fore.MAGENTA}Effective Configuration:{Style.RESET_ALL}', end='  ')
    for label, color in COLORS.items():
        print(f'{color}\u25A0 {label}{Style.RESET_ALL}', end='  ')
    print('\n')

    for key, (value, source) in sorted(effective.items()):
        print(f'    {COLORS[source]}{key}: {value}{Style.RESET_ALL}')


if __name__ == '__main__':
    main()

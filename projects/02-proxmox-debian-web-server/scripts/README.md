# Windows deployment scripts

These copies come from the original scripts supplied by the lab owner on 9 October 2026. Personal paths, the SSH username and server address are replaced with placeholders; the original workflow is preserved. The batch filename's duplicate-download suffix has been removed.

## Setup

Put both scripts in your website working directory. Set the batch file's `cd /d` path and PowerShell's `$LocalFolder` to that directory (the example uses `C:\Lab\Web`). Replace `YOUR_SSH_USER` and `YOUR_SERVER_IP` in the PowerShell script, including the displayed browser URLs.

Requirements: Windows PowerShell, the OpenSSH client providing `scp`, GitHub access, SSH access to the target, and write permission on `/var/www/html/`. Use your existing SSH key setup and verify the server host key. Never commit passwords or private keys.

Double-click `update-and-deploy-web01.bat`. It downloads four pages from this repository's `main/website/` directory, then invokes `deploy-web01.ps1` to copy HTML files to Nginx's document root.

## Limitations and validation

The original batch does not stop after a failed download, so it could deploy mixed old and new files. PowerShell returns exit code 1 on an scp failure, but the batch does not explicitly propagate it. Files are replaced directly, not atomically.

These public copies were inspected, not executed against the live server. They retain the original implementation's behaviour and require the placeholders to be filled in before use.

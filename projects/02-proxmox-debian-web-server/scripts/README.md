# Windows deployment scripts

These sanitised scripts implement the website update workflow used for `web01`. Set the connection placeholders before running them; passwords and private keys do not belong in the repository.

## What the workflow does

1. The batch launcher runs the PowerShell deployment script and propagates its exit code.
2. PowerShell downloads the five pages from this repository into a unique temporary directory.
3. Every file must exist, contain data, and include opening and closing HTML elements.
4. Only after all four checks pass are the local working copies replaced.
5. The validated staging files are uploaded to Nginx's document root with `scp`.
6. The temporary directory is removed whether the run succeeds or fails.

A failed download or validation stops the workflow before `scp` runs, preventing a mixture of old and newly downloaded pages from being deployed.

## Setup

Keep both files in the same directory. In `deploy-web01.ps1`, configure:

- `$LocalFolder`: the folder that stores the downloaded website pages.
- `$Server`: the SSH destination in `user@server` form.
- `$RemotePath`: the Nginx document root, normally `/var/www/html/`.

Requirements:

- Windows PowerShell and the Windows OpenSSH client providing `scp`.
- Network access to GitHub and the server's SSH port.
- Existing SSH authentication and permission to write to the remote path.
- A previously verified SSH host key.

Double-click `update-and-deploy-web01.bat` to run the workflow.

## Failure handling

The script returns a nonzero exit code when configuration, download, validation or `scp` fails. The batch launcher reports that failure and returns exit code 1.

The HTML checks detect empty files and common error responses, but they do not validate every link or visual detail. Deployment still replaces the five remote files through `scp`; browser verification remains the final check.

The public version uses placeholders for personal paths and connection details. It was reviewed for control flow in the repository; live deployment requires the configured copy on the lab PC.

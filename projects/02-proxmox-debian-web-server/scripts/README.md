# Windows deployment scripts

Keep both scripts in the same directory. Configure Server and SiteUrl in deploy-web01.ps1; LocalFolder defaults to that script's directory. Set RemotePath to the Nginx document root, normally /var/www/html/.

Double-click update-and-deploy-web01.bat. The BAT only launches PowerShell; all download, upload and verification logic lives in the PowerShell script.

## Update process

1. Resolve the current main commit through GitHub's API using a unique request URL.
2. Download all five pages from that exact commit into a temporary directory.
3. Reject missing, empty or incomplete HTML files before any upload.
4. Save local copies and upload only those five validated files through scp.
5. Fetch each page from the configured website URL with unique query parameters.
6. Compare each served file's SHA-256 hash with the corresponding downloaded file.
7. Report success only when all five served pages match. Print the deployed commit and revision-specific page links.
8. Remove temporary files on success or failure.

## Requirements and limits

- Windows PowerShell 5.1 or later and OpenSSH scp.
- Access to GitHub's API, raw file hosting, the SSH server and the website.
- Existing SSH authentication, a verified host key and write permission for the remote directory.
- Public repository access; unauthenticated GitHub API rate limits apply.
- Configure SiteUrl to the actual hostname or address you use to open the website.

Download failures stop before upload. Upload or verification failures return exit code 1. An interrupted upload can leave a partially updated remote website; this workflow does not provide atomic deployment or rollback. HTTP verification checks exact file content, not appearance or browser cache.

The public scripts use connection placeholders. Live validation requires the configured scripts on the lab PC.

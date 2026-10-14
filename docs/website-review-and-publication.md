# Website review and publication

## Working model

Edit the `draft` branch, automatically refresh its homepage, deploy that exact draft to `web01`, review it, then merge the approved version into `main`. GitHub Actions publishes `website/` from `main` to GitHub Pages. Drafts never enter the publication job.

GitHub remains the source repository. The PC folder is a deployment copy, and `web01` is the private review server. Both are refreshed from a single commit. Draft source remains publicly readable because this repository is public.

## One-time setup

1. In repository **Settings → Pages → Build and deployment**, set **Source** to **GitHub Actions**. The previous publishing history used the root of `gh-pages`; retain that branch as historical output, but stop publishing from it.
2. Save the current `scripts/deploy-web01.ps1` and `scripts/update-web01.bat` in `C:\Users\admin\Documents\Labs\Web\scripts\` on the admin PC. The launcher does not update itself.
3. Keep existing SSH key authentication to `web01`. No GitHub token is needed on the PC to download this public repository.
4. For enforced review, optionally protect `main` with a rule requiring pull requests and disallowing direct pushes. The workflow itself does not enforce a human approval or prevent an owner from pushing directly to `main`.

The Pages setting must be changed before the first approved merge can publish through the new workflow. No new service account or personal access token is required.

## Edit and review, with or without ChatGPT

1. Select **draft** in GitHub before editing. Alternatively, edit a local Git checkout of that branch and push it. ChatGPT can make these same changes through the GitHub connector.
2. Open **Actions → Website sync and publication**. Wait for the draft preparation job to succeed. It runs the generator and commits only `website/index.html` when needed. Its summary names the final prepared commit, which may differ from the triggering commit.
3. Double-click `update-web01.bat`. Its default is `draft`. It refuses a commit without a successful `homepage-sync` status, downloads all six pages from one commit, uploads them, and compares served-file SHA256 hashes.
4. Review all affected pages on `web01`, including mobile layouts where relevant. The local `web01-deployment.json` file records the reviewed branch, commit and file hashes after successful verification. Save that commit number for approval.
5. If corrections are needed, edit `draft` again and repeat the deployment and review. A new commit requires a new review. The deployment script cannot determine visual approval.

## Publish the reviewed version yourself

1. On GitHub choose **Pull requests → New pull request**; set **base: main**, **compare: draft**.
2. Compare the current draft head commit with the commit in `web01-deployment.json`. They must match. Record the reviewed commit in the pull request description.
3. Inspect the Files changed tab and confirm there are no changes beyond what you reviewed. If GitHub asks to update the branch or resolve conflicts, do that first, then repeat preparation and review on `web01`.
4. Choose **Create a merge commit**, then merge after approval. Keep the `draft` branch. Avoid squash/rebase here so the ongoing draft branch retains shared history with main.
5. Watch the **Website sync and publication** run for `main`. It checks that the committed homepage is already current, then publishes those exact website files. It never silently regenerates approved content on main.
6. Check the public URL and the deployment result. A successful merge is not proof of successful publication.
7. Before the next editing cycle, merge the latest `main` into `draft` without overwriting draft work. The connector can do this; locally use `git switch draft`, `git fetch origin`, `git merge origin/main`, then `git push origin draft`. Never force-push to bypass a conflict.

With ChatGPT, say “Publish reviewed commit <SHA>.” The assistant should compare the draft head with that exact SHA and use it as the expected head when merging. You can perform every step through GitHub without ChatGPT.

## Deploying the approved version to web01

The usual review launcher targets draft. To replace it with the approved main version, run:

```bat
update-web01.bat main
```

Wait for main preparation to succeed first. Publication and internal deployment are independent: GitHub cannot reach the private lab server, and the PC deployer does not publish to GitHub Pages.

## Failures and recovery

- **Homepage sync fails:** inspect the Actions log; missing files, malformed markers, or insufficient entries stop the run. Fix draft and push again.
- **Draft advances during sync:** the push is rejected rather than forced; the newer workflow processes the newer commit.
- **Deployment says not ready:** wait for the current commit's preparation job; do not bypass the guard.
- **SCP or served-file hashes fail:** treat the internal deployment as unverified. Retry after resolving the error; an interrupted upload can leave partial updates.
- **Pages fails:** inspect the publication job and confirm Pages uses GitHub Actions. The previously published site is not evidence that the new publication succeeded.
- **Rollback:** revert the unwanted change on draft, review the resulting website, and merge through the same process. Preserve history.

The workflow uses GitHub's built-in token. Its generated draft commit does not start a second workflow; the same run validates and marks the final commit ready. Only main uses the Pages deployment action. No public deployment is attempted from draft.

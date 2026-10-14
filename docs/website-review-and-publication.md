# Website review and publication

## Working model

Agree the website changes in ChatGPT, then commit them to `draft`. When you run `update-web01.bat`, the launcher downloads those pages, runs AUT-002 on the downloaded copy, and AUT-001 deploys it to internal `web.internal` for review. After approval, merge the same website changes into `main`. GitHub Actions runs AUT-002 on `main` and publishes the generated `website/` to GitHub Pages. Draft changes do not trigger the publication workflow.

GitHub remains the source repository. The PC folder is a deployment copy, and `web01` is the private review server. Both are refreshed from a single commit. Draft source remains publicly readable because this repository is public.

## One-time setup

1. In repository **Settings → Pages → Build and deployment**, set **Source** to **GitHub Actions**. The previous publishing history used the root of `gh-pages`; retain that branch as historical output, but stop publishing from it.
2. Save the current `scripts/deploy-web01.ps1` and `scripts/update-web01.bat` in `C:\Users\admin\Documents\Labs\Web\scripts\` on the admin PC. The launcher does not update itself.
3. Keep existing SSH key authentication to `web01`. No GitHub token is needed on the PC to download this public repository.
4. For enforced review, optionally protect `main` with a rule requiring pull requests and disallowing direct pushes. The workflow itself does not enforce a human approval or prevent an owner from pushing directly to `main`.

The public site is recorded as live from the earlier `gh-pages` setup. The Pages setting must be changed before the first approved merge can publish through the Actions workflow; its first successful publication is not recorded here. No new service account or personal access token is required.

## Edit and review, with or without ChatGPT

1. We agree the changes in ChatGPT and update `draft`.
2. Double-click `update-web01.bat`. It downloads the latest draft pages, runs AUT-002 to refresh homepage previews, and deploys all six pages to internal `web.internal`.
3. Review the website on `web.internal`. The deployment receipt records the reviewed branch, commit, and file hashes.
4. If corrections are needed, make them in ChatGPT and repeat the review.
5. When ready, merge the same website changes into `main`. GitHub Actions runs AUT-002 and publishes the generated site to GitHub Pages.

## Publish the reviewed version yourself

1. On GitHub choose **Pull requests → New pull request**; set **base: main**, **compare: draft**.
2. Compare the current draft head commit with the commit in `web01-deployment.json`. They must match. Record the reviewed commit in the pull request description.
3. Inspect the Files changed tab and confirm there are no changes beyond what you reviewed. If GitHub asks to update the branch or resolve conflicts, do that first, then repeat preparation and review on `web01`.
4. Choose **Create a merge commit**, then merge after approval. Keep the `draft` branch. Avoid squash/rebase here so the ongoing draft branch retains shared history with main.
5. Watch the **Website build and publication** run for `main`. It runs AUT-002 on the merged website files, then publishes the generated output. The `draft` branch does not start this workflow.
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
- **Homepage generation fails:** AUT-002 stops before upload. Check the error from the launcher, correct the missing or malformed source content, and run it again.
- **SCP or served-file hashes fail:** treat the internal deployment as unverified. Retry after resolving the error; an interrupted upload can leave partial updates.
- **Pages fails:** inspect the publication job and confirm Pages uses GitHub Actions. The previously published site is not evidence that the new publication succeeded.
- **Rollback:** revert the unwanted change on draft, review the resulting website, and merge through the same process. Preserve history.

The workflow uses GitHub's built-in token. Its generated draft commit does not start a second workflow; the same run validates and marks the final commit ready. Only main uses the Pages deployment action. No public deployment is attempted from draft.

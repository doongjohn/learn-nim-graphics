git config --global --unset user.name &&
git config --global --unset user.email &&
git config --global --unset credential.helper &&
git config --system --unset credential.helper &&
cmdkey /delete git:https://github.com &&
cmdkey /delete vscodevscode.github-authentication/github.auth

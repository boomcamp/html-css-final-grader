#!/usr/bin/env node

const fs = require('fs');
const github = require('@octokit/rest')();
const argv = require('yargs').argv
const { promisify } = require('util');

const writeFileAsync = promisify(fs.writeFile);

async function downloadRepoArchives(archConfigs) {
  archConfigs.forEach(async (config) => {
    const repoArchive = await github.repos.getArchiveLink(config)
    await writeFileAsync(`${config.owner}_${config.repo}.tar`, repoArchive.data)
  })
}

(async function() {
  const finalRepoPulls = await github.pulls.list({
    owner: 'boomcamp',
    repo: 'html-css-final',
    state: 'open',
    sort: 'created',
    per_page: 100,
  })

  const prRepos = finalRepoPulls.data.map(pr => {
    return {
      owner: pr.user.login,
      repo: pr.head.repo.name,
      archive_format: 'tarball',
      ref: 'master',
    }
  })

  try {
    await downloadRepoArchives(prRepos);
  } catch (e) {
    console.error(e);
  }
})()

// const core = require('@actions/core');
// const github = require('@actions/github');
const exec = require('child_process').exec;
// const fs = require('fs');

try {
    installGoods(() => {
        sayDone();
    });
} catch (e) {
    // core.setFailed(error.message);
    console.log(e.message);
}

function sayDone() {
    console.log('I think we are done!');
}

function installGoods(next) {
    const cmd1 = `
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    `;
    const cmd2 = `sudo apt update && sudo apt install yarn`;
    const cmd3 = `yarn --version`;
    exec(`${cmd1} && ${cmd2} && ${cmd3}`, (error, stdout, stderr) => {
        if (error) throw stderr;
        next();
    });
}

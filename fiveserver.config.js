// fiveserver.config.js
module.exports = {
    watch: '.',
    ignore: /.*target.*/,
    highlight: true, // enable highlight feature
    injectBody: true, // enable instant update
    remoteLogs: false, // enable remoteLogs
    remoteLogs: "yellow", // enable remoteLogs and use the color yellow
    injectCss: false, // disable injecting css
    navigate: true, // enable auto-navigation
};
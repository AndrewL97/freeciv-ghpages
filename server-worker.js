self.Module = {
    arguments: [],

    print: (...args) => console.log("[server]", ...args),
    printErr: (...args) => console.error("[server]", ...args),

    onRuntimeInitialized: () => {
        console.log("[server] Runtime initialized");
    },

    onAbort: (reason) => {
        console.error("[server] Aborted:", reason);
    }
};

importScripts("./freeciv-server.js");
self.onerror = (event) => {
    console.error("[server] Worker error:", event);
};

self.Module = {
    arguments: [],

    print: (...args) => {
        console.log("[server]", ...args);
        self.postMessage({ type: "stdout", message: args.join(" ") });
    },

    printErr: (...args) => {
        console.error("[server]", ...args);
        self.postMessage({ type: "stderr", message: args.join(" ") });
    },

    onRuntimeInitialized: () => {
        console.log("[server] Runtime initialized");
        self.postMessage({ type: "runtime-initialized" });
    },

    onAbort: (reason) => {
        console.error("[server] Aborted:", reason);
        self.postMessage({ type: "abort", reason: String(reason) });
    }
};

importScripts("./freeciv-server.js");
self.postMessage({ type: "script-loaded" });

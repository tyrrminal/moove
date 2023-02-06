module.exports = {
  devServer: {
    allowedHosts: "all",
    host: '0.0.0.0',

    headers: {
      "Access-Control-Allow-Origin": "*",
    },

    client: {
      webSocketURL: "auto://0.0.0.0:0/ws",
    },
  }
}
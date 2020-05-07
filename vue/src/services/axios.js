import axios from "axios";

const serverURL = process.env.VUE_APP_API_URL || "";

const instance = axios.create({
  baseURL: serverURL + "/api/v1/",
  withCredentials: true,
  crossDomain: true,
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json"
  }
});

export default instance;

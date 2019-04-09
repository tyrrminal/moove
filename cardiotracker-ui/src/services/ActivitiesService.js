import axios from "axios";

const serverURL = "https://ct.digicow.net";

const apiClient = axios.create({
  baseURL: serverURL + "/api/v1",
  withCredentials: false,
  crossDomain: true,
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json"
  }
});

export default {
  getSummary(username) {
    return apiClient.get("legacy/summary/" + username);
  },
  getActivities(username, page, perPage) {
    const params = new URLSearchParams();
    params.append("page", page);
    params.append("perPage", perPage);
    return apiClient.get("legacy/summary/" + username, { params: params });
  },
  getEvents(username) {
    return apiClient.get("legacy/events/" + username);
  }
};

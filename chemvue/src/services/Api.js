import axios from "axios";

export default () => {
  return axios.create({
    baseURL: `${process.env.VUE_APP_ROOT_API}${process.env.VUE_APP_SERVER_BASE_PATH}api`,
    withCredentials: false,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json"
    }
  });
};
import Branding from "@/constants/branding.js";

export default {
  computed: {
    companyFullname: () => Branding.ORGANIZATION,
    companyName: () => Branding.COMPANY,
    companyDomain: () => Branding.DOMAIN,

    applicationName: () => Branding.APP,
    applicationFullname: () => Branding.FULLNAME,

    applicationDescription: () => Branding.DESCRIPTION,
  }
}
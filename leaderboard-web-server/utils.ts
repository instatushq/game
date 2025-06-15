type SocialMedia =
  | "X"
  | "YOUTUBE"
  | "FACEBOOK"
  | "LINKEDIN"
  | "GITHUB"
  | "INSTAGRAM";

interface SocialMediaValidationResult {
  isValid: boolean;
  platform: SocialMedia | null;
  normalizedUrl?: string;
}

export function isEmptyOrWhitespace(str: string): boolean {
  if (!str || typeof str !== "string") return true;
  return str.trim().length === 0;
}

export function validateSocialMediaUrl(
  url: string
): SocialMediaValidationResult {
  if (!url || typeof url !== "string")
    return { isValid: false, platform: null };

  const cleanUrl = url.trim().toLowerCase().replace(/\s+/g, "");

  if (cleanUrl === "") return { isValid: false, platform: null };

  if (cleanUrl.includes("x.com/") || cleanUrl.includes("twitter.com/")) {
    const xPattern =
      /^https?:\/\/(www\.)?(x\.com|twitter\.com)\/[a-zA-Z0-9_]{1,15}\/?$/;
    if (xPattern.test(cleanUrl)) {
      return {
        isValid: true,
        platform: "X",
        normalizedUrl: cleanUrl.replace("twitter.com", "x.com"),
      };
    }
  }

  if (cleanUrl.includes("youtube.com/") || cleanUrl.includes("youtu.be/")) {
    const isYoutubeChannel =
      /^https?:\/\/(www\.)?youtube\.com\/(channel\/|c\/|user\/)[a-zA-Z0-9_-]+\/?$/.test(
        cleanUrl
      );
    const isYoutubeAt =
      /^https?:\/\/(www\.)?youtube\.com\/@[a-zA-Z0-9_-]+\/?$/.test(cleanUrl);
    const isYoutubeShort =
      /^https?:\/\/(www\.)?youtu\.be\/[a-zA-Z0-9_-]+\/?$/.test(cleanUrl);

    if (isYoutubeChannel || isYoutubeAt || isYoutubeShort) {
      return {
        isValid: true,
        platform: "YOUTUBE",
        normalizedUrl: cleanUrl,
      };
    }
  }

  if (cleanUrl.includes("facebook.com/")) {
    const facebookPattern =
      /^https?:\/\/(www\.)?facebook\.com\/[a-zA-Z0-9.]+\/?$/;
    if (facebookPattern.test(cleanUrl)) {
      return {
        isValid: true,
        platform: "FACEBOOK",
        normalizedUrl: cleanUrl,
      };
    }
  }

  if (cleanUrl.includes("linkedin.com/")) {
    const linkedinPattern =
      /^https?:\/\/(www\.)?linkedin\.com\/(in\/[a-zA-Z0-9-]+|company\/[a-zA-Z0-9-]+)\/?$/;
    if (linkedinPattern.test(cleanUrl)) {
      return {
        isValid: true,
        platform: "LINKEDIN",
        normalizedUrl: cleanUrl,
      };
    }
  }

  if (cleanUrl.includes("github.com/")) {
    const githubPattern = /^https?:\/\/(www\.)?github\.com\/[a-zA-Z0-9-]+\/?$/;
    if (githubPattern.test(cleanUrl)) {
      return {
        isValid: true,
        platform: "GITHUB",
        normalizedUrl: cleanUrl,
      };
    }
  }

  if (cleanUrl.includes("instagram.com/")) {
    const instagramPattern =
      /^https?:\/\/(www\.)?instagram\.com\/[a-zA-Z0-9_.]+\/?$/;
    if (instagramPattern.test(cleanUrl)) {
      return {
        isValid: true,
        platform: "INSTAGRAM",
        normalizedUrl: cleanUrl,
      };
    }
  }

  return { isValid: false, platform: null };
}

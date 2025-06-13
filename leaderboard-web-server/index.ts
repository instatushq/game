import express from "express";
import cors from "cors";
import { getTopPlayers, addScore, getScoreRank } from "./leaderboard";
const port = 3000;
const app = express();
app.use(
  cors({
    origin: [
      /^https?:\/\/(.*\.)?instatus\.co$/,
      /^https?:\/\/(.*\.)?instatus\.app$/,
      /^https?:\/\/(.*\.)?supstatus\.com$/,
      /^https?:\/\/(.*\.)?instatus\.io$/,
      /^https?:\/\/(.*\.)?instatus\.com$/,
    ],
  })
);

const exactDateNow: string = new Date()
  .toLocaleString("en-US", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  })
  .replace(",", "");
app.use(express.json());

enum SocialMedia {
  X = "X",
  INSTAGRAM = "INSTAGRAM",
  TIKTOK = "TIKTOK",
  YOUTUBE = "YOUTUBE",
  FACEBOOK = "FACEBOOK",
  TWITTER = "TWITTER",
  LINKEDIN = "LINKEDIN",
}

app.get("/ping", (_, res) => {
  res.send("last deployment: " + exactDateNow);
});

app.get("/leaderboard", async (req, res) => {
  try {
    const players_count = Number(req.query.players ?? 10);
    if (isNaN(players_count)) {
      res.status(400).send("Players count must be a number");
      return;
    }
    if (players_count < 1 || players_count > 100) {
      res.status(400).send("Players count must be between 1 and 100");
      return;
    }
    const topPlayers = await getTopPlayers(players_count);
    res.json(topPlayers);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal server error");
  }
});

app.get("/leaderboard/rank/:score", async (req, res) => {
  const { score } = req.params;
  if (!score) {
    res.status(400).send("Score is required");
    return;
  }
  if (isNaN(Number(score))) {
    res.status(400).send("Score must be a number");
    return;
  }
  if (Number(score) < 0 || Number(score) > Number.MAX_SAFE_INTEGER) {
    res.status(400).send("Score must be greater than 0");
    return;
  }

  try {
    const rank = await getScoreRank(Number(score));
    res.json({
      rank: rank,
      score: Number(score),
    });
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal server error");
  }
});

app.post("/leaderboard", async (req, res) => {
  let { name, score, socialMediaUrl } = req.body;

  // Trim the name and normalize multiple spaces to single space
  if (typeof name === "string") {
    name = name.trim().replace(/\s+/g, " ");
  }

  if (
    name === null ||
    name === undefined ||
    score === null ||
    score === undefined
  ) {
    res.status(400).send("Name and score are required");
    return;
  }
  if (!(score >= 0 && score < Number.MAX_SAFE_INTEGER)) {
    res
      .status(400)
      .send("Score must be between 0 and " + Number.MAX_SAFE_INTEGER);
    return;
  }

  if (!(name.length > 2 && name.length <= 24)) {
    res.status(400).send("Name must be 24 characters or less");
    return;
  }

  try {
    const newScore = await addScore(name, score, {
      url: socialMediaUrl,
      socialMedia: SocialMedia.X,
    });
    res.json(newScore);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal server error");
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

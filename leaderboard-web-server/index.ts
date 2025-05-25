import express from "express";
import { getTopPlayers, addScore, getScoreRank } from "./leaderboard";
const port = 3000;
const app = express();
app.use(express.json());

app.get("/leaderboard", async (_, res) => {
  try {
    const topPlayers = await getTopPlayers();
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
  const { name, score } = req.body;
  if (
    name === null ||
    name === undefined ||
    score === null ||
    score === undefined
  ) {
    res.status(400).send("Name and score are required");
    return;
  }
  if (name.length > 3) {
    res.status(400).send("Name must be 3 characters or less");
    return;
  }
  if (!(score >= 0 && score < Number.MAX_SAFE_INTEGER)) {
    res
      .status(400)
      .send("Score must be between 0 and " + Number.MAX_SAFE_INTEGER);
    return;
  }
  try {
    const newScore = await addScore(name, score);
    res.json(newScore);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal server error");
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

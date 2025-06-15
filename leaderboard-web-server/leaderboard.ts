import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

export async function getTopPlayers(amount: number = 10) {
  return await prisma.scores.findMany({
    orderBy: [{ score: "desc" }, { createdAt: "desc" }],
    take: amount,
  });
}

export async function getScoreRank(score: number) {
  const rank = await prisma.scores.count({
    where: {
      score: {
        gt: score,
      },
    },
  });
  return rank + 1;
}

export async function addScore(
  name: string,
  score: number,
  socialMediaURL = ""
) {
  const topPlayers = await prisma.scores.findMany({
    where: {
      name: {
        mode: "insensitive",
        equals: name,
      },
    },
    orderBy: { score: "desc" },
    take: 1,
  });

  if (topPlayers.length > 0) {
    if (score > topPlayers[0].score) {
      return prisma.scores.update({
        where: { id: topPlayers[0].id },
        data: { score },
      });
    }
    return topPlayers[0];
  } else {
    return prisma.scores.create({
      data: {
        name,
        score,
        socialMediaUrl: socialMediaURL,
      },
    });
  }
}

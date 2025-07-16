import {
  RegExpMatcher,
  englishDataset,
  englishRecommendedTransformers,
} from "obscenity";

const matcher = new RegExpMatcher({
  ...englishDataset.build(),
  ...englishRecommendedTransformers,
});

function containsProfanity(text: string): boolean {
  return matcher.hasMatch(text);
}

export { containsProfanity };

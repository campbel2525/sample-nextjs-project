// @ts-check

import { dirname } from "path";
import { fileURLToPath } from "url";
import prettierConfig from "eslint-config-prettier";
import eslintRecommended from "@eslint/js";
import tseslint from "typescript-eslint";
import globals from "globals";

const projectRoot =
  import.meta.dirname || dirname(fileURLToPath(import.meta.url));

export default [
  // 1. グローバルな設定と無視するファイル (単一の設定オブジェクト)
  {
    ignores: [
      "node_modules/",
      "dist/",
      ".next/",
      "coverage/",
      "**/build/",
      "apps/**/.next/",
      "apps/**/dist/",
      "apps/**/build/",
      "packages/**/dist/",
      "packages/**/build/",
      "*.config.js",
      "*.config.mjs",
      "*.config.ts",
      "**/*.d.ts",
      "eslint.config.mjs",
      "apps/**/eslint.config.mjs",
    ],
  },

  // 2. ESLint の基本的な推奨ルール (単一の設定オブジェクト)
  eslintRecommended.configs.recommended,

  // 3. TypeScript-ESLint の基本・厳格ルールを適用するための複数の設定オブジェクト
  // 各 recommended config はそれ自体が配列なので、個別にスプレッドしてトップレベルに配置します。
  // そして、これらに共通する言語オプションやパーサーオプションは、別途オブジェクトで定義します。
  ...tseslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,

  // TypeScript ファイルの言語オプション設定 (単一の設定オブジェクト)
  // これは上記の recommended config とは別の、独立した設定オブジェクトとして配列に含めます。
  {
    files: ["**/*.ts", "**/*.tsx"],
    languageOptions: {
      parserOptions: {
        project: [
          "./tsconfig.json",
          "./apps/*/tsconfig.json",
          "./packages/*/tsconfig.json",
        ],
        tsconfigRootDir: projectRoot,
      },
    },
    // TypeScript 固有のルールカスタマイズはここに記述
    // '@typescript-eslint/no-explicit-any': 'warn', // 必要であれば
    // '@typescript-eslint/no-unsafe-function-type': 'warn',
  },

  // ★ Next.js 固有の設定ブロックは、`eslint-config-next` を使わないためここにはありません。 ★

  // 4. 実行環境のグローバル変数を設定 (単一の設定オブジェクト)
  {
    files: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.browser,
      },
    },
  },

  // 5. 共通のルールカスタマイズ (単一の設定オブジェクト)
  {
    files: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"],
    rules: {
      "no-console": "warn",
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unsafe-function-type": "warn",
    },
  },

  // 6. Prettierとの競合回避設定 (単一の設定オブジェクト - 必ず配列の最後に置く)
  prettierConfig,
];

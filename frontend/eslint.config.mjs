import globals from "globals";
import pluginVue from "eslint-plugin-vue";

/** @type {import('eslint').Linter.FlatConfig[]} */
export default [
  { files: ["**/*.{js,mjs,cjs,vue}"] },
  { languageOptions: { globals: globals.browser } },
  ...pluginVue.configs["flat/essential"],
  {
    rules: {
      "vue/multi-word-component-names": "off"
    }
  },
  {
    files: ["src/components/UpdateQuiz.vue"],
    rules: {
      "vue/no-unused-vars": "off"
    }
  },
  {
    files: ["src/layouts/Header.vue"],
    rules: {
      "vue/return-in-computed-property": "off",
      "vue/no-async-in-computed-properties": "off"
    }
  }
];

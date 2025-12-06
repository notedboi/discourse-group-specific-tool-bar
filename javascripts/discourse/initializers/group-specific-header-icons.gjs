import curryComponent from "ember-curry-component";
import { getOwnerWithFallback } from "discourse/lib/get-owner";
import { withPluginApi } from "discourse/lib/plugin-api";
import CustomHeaderIconLinks from "../components/custom-header-icon-links";

const BEFORE_ICONS = ["chat", "search", "hamburger", "user-menu"];

export default {
  name: "group-specific-header-icons",
  initialize() {
    withPluginApi((api) => {
      api.headerIcons.add(
        "group-specific-header-icons",
        curryComponent(CustomHeaderIconLinks, {}, getOwnerWithFallback()),
        {
          before: BEFORE_ICONS,
        }
      );
    });
  },
};

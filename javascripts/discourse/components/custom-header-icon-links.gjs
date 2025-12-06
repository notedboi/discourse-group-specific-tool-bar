/* global settings */
import Component from "@glimmer/component";
import { service } from "@ember/service";
import CustomHeaderIcon from "./custom-header-icon";

const DEFAULT_VIEW = "vdm";
const DEFAULT_TARGET = "self";

function splitAndClean(value = "", delimiter = "|") {
  return value
    .split(delimiter)
    .map((entry) => entry.trim())
    .filter(Boolean);
}

function parseLinkDefinition(linkDefinition) {
  const fragments = linkDefinition.split(",").map((fragment) => fragment.trim());

  if (!fragments[0]) {
    return null;
  }

  return {
    title: fragments[0],
    icon: fragments[1],
    url: fragments[2],
    view: (fragments[3] || DEFAULT_VIEW).toLowerCase(),
    target: (fragments[4] || DEFAULT_TARGET).toLowerCase(),
    width: fragments[5],
  };
}

function parseLinks(definition = "") {
  return splitAndClean(definition)
    .map(parseLinkDefinition)
    .filter(Boolean);
}

export default class CustomHeaderIconLinks extends Component {
  @service currentUser;

  get links() {
    return parseLinks(this.#linkSettingForUser());
  }

  #linkSettingForUser() {
    if (!this.currentUser) {
      return settings.Header_links_for_not_login_user;
    }

    if (settings.group_set_1 && this.#userIsInGroups(settings.group_set_1)) {
      return settings.Header_links_set_1;
    }

    if (settings.group_set_2 && this.#userIsInGroups(settings.group_set_2)) {
      return settings.Header_links_set_2;
    }

    if (settings.exclude_group) {
      return this.#userIsInGroups(settings.exclude_group)
        ? ""
        : settings.Header_links_for_other_group;
    }

    return "";
  }

  #userIsInGroups(listSetting) {
    const groups = splitAndClean(listSetting);
    if (!groups.length || !this.currentUser?.groups?.length) {
      return false;
    }

    const normalizedUserGroups = this.currentUser.groups
      .map((group) => group?.name?.toLowerCase())
      .filter(Boolean);

    return groups
      .map((group) => group.toLowerCase())
      .some((group) => normalizedUserGroups.includes(group));
  }

  <template>
    {{#each this.links as |link|}}
      <CustomHeaderIcon @link={{link}} @links={{this.links}} />
    {{/each}}
  </template>
}

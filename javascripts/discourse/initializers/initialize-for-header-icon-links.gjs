import {
  withPluginApi
} from "discourse/lib/plugin-api";
import icon from "discourse-common/helpers/d-icon";
import {
  dasherize
} from "@ember/string";

function buildIcon(iconNameOrImageUrl, title) {
  if (isValidUrl(iconNameOrImageUrl)) {
    return <template>
      <img src="{{iconNameOrImageUrl}}" aria-hidden="true"/>
      <span class="sr-only">{{title}}</span>
    </template>
  } else {
    return <template>{{icon iconNameOrImageUrl label=title}}</template>
  }
}

export default {
  name: "target-specific-header-icon-links",
  initialize() {
    withPluginApi("0.8.41", (api) => {

      const render = (Header_links) => {
        try {
          const splitLinks = Header_links.split("|").filter(Boolean);

          splitLinks.forEach((link, index, links) => {
            const fragments = link.split(",").map((fragment) => fragment.trim());
            const title = fragments[0];
            const iconTemplate = buildIcon(fragments[1], title);
            const href = fragments[2];
            const className = `header-icon-${dasherize(fragments[0])}`;
            const viewClass = fragments[3].toLowerCase();
            const target = fragments[4].toLowerCase() === "blank" ? "_blank" : "";
            const rel = target ? "noopener" : "";
            const isLastLink =
            link === links[links.length - 1] ? "last-custom-icon" : "";


            const iconComponent = <template>
            <li class="custom-header-icon-link {{className}} {{viewClass}} {{isLastLink}}">
              <a class="icon btn-flat"
              href={{href}}
              title={{title}}
              target={{target}}
              rel={{rel}}
              >
                {{iconTemplate}}
              </a>
            </li>
          </template>

          const beforeIcon = ['chat', 'search', 'hamburger', 'user-menu']

          api.headerIcons.add(title, iconComponent, { before: beforeIcon })
          
          });
        } catch (error) {
          console.error(error);
          console.error(
            "There's an issue in the header icon links component. Check if your settings are entered correctly"
          );
        }
      }

      const checkGroup = (groups) => {
        const userGroup = currentUser.groups.map(u => u.name);

        const found = groups.split('|').some(r => userGroup.indexOf(r) >= 0)

        return found
      }

      const currentUser = api.getCurrentUser();

      if (currentUser == null) {
        render(settings.Header_links_for_not_login_user)
        return;
      }

      if (settings.group_set_1) {
        if (checkGroup(settings.group_set_1)) {
          render(settings.Header_links_set_1)
          return;

        }
      }

      if (settings.group_set_2) {
        if (checkGroup(settings.group_set_2)) {
          render(settings.Header_links_set_2)
          return;
        }
      }

      if (settings.exclude_group) {
        if (!checkGroup(settings.exclude_group)) {
          render(settings.Header_links_for_other_group)
          return
        }
      }

    });
  },
};

<<<<<<< HEAD
{{#if this.appendReason}}
  <p class="reason">
    <PinnedOptions @value={{this.pinned}} @topic={{this.topic}} />
    <span class="text">{{html-safe this.reasonText}}</span>
  </p>
{{else}}
  <PinnedOptions @value={{this.pinned}} @topic={{this.topic}} />
{{/if}}
=======
import Component from "@ember/component";
import { classNameBindings, classNames } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { pluginApiIdentifiers } from "select-kit/components/select-kit";

@classNames("pinned-button")
@classNameBindings("isHidden")
@pluginApiIdentifiers("pinned-button")
export default class PinnedButton extends Component {
  descriptionKey = "help";
  appendReason = true;

  @discourseComputed("topic.pinned_globally", "pinned")
  reasonText(pinnedGlobally, pinned) {
    const globally = pinnedGlobally ? "_globally" : "";
    const pinnedKey = pinned ? `pinned${globally}` : "unpinned";
    const key = `topic_statuses.${pinnedKey}.help`;
    return i18n(key);
  }

  @discourseComputed("pinned", "topic.deleted", "topic.unpinned")
  isHidden(pinned, deleted, unpinned) {
    return deleted || (!pinned && !unpinned);
  }
}
>>>>>>> a9ddbde3f6 (DEV: [gjs-codemod] renamed js to gjs)

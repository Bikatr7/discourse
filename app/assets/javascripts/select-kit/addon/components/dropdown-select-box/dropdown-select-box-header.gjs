<<<<<<< HEAD
<div class="select-kit-header-wrapper">
  {{#each this.icons as |icon|}} {{d-icon icon}} {{/each}}

  {{component
    this.selectKit.options.selectedNameComponent
    tabindex=this.tabindex
    item=this.selectedContent
    selectKit=this.selectKit
    shouldDisplayClearableButton=this.shouldDisplayClearableButton
  }}

  {{#if this.selectKit.options.showCaret}}
    {{d-icon this.caretIcon class="caret-icon"}}
  {{/if}}
  &#8203;
  {{! Zero-width space character, so icon-only button height = regular button height }}
</div>
=======
import { computed } from "@ember/object";
import { readOnly } from "@ember/object/computed";
import { classNameBindings, classNames } from "@ember-decorators/component";
import SingleSelectHeaderComponent from "select-kit/components/select-kit/single-select-header";

@classNames("dropdown-select-box-header")
@classNameBindings("btnClassName", "btnStyleClass", "btnCustomClasses")
export default class DropdownSelectBoxHeader extends SingleSelectHeaderComponent {
  @readOnly("selectKit.options.showFullTitle") showFullTitle;
  @readOnly("selectKit.options.customStyle") customStyle;
  @readOnly("selectKit.options.btnCustomClasses") btnCustomClasses;
  @readOnly("selectKit.options.caretUpIcon") caretUpIcon;
  @readOnly("selectKit.options.caretDownIcon") caretDownIcon;

  @computed("showFullTitle")
  get btnClassName() {
    return `btn ${this.showFullTitle ? "btn-icon-text" : "no-text btn-icon"}`;
  }

  @computed("customStyle")
  get btnStyleClass() {
    return `${this.customStyle ? "" : "btn-default"}`;
  }

  @computed("selectKit.isExpanded", "caretUpIcon", "caretDownIcon")
  get caretIcon() {
    return this.selectKit.isExpanded ? this.caretUpIcon : this.caretDownIcon;
  }
}
>>>>>>> a9ddbde3f6 (DEV: [gjs-codemod] renamed js to gjs)

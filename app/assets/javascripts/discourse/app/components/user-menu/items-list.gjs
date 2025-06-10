<<<<<<< HEAD
<PluginOutlet
  @name="before-panel-body"
  @outletArgs={{hash closeUserMenu=@closeUserMenu}}
/>
{{#if this.loading}}
  <div class="spinner-container">
    <div class="spinner"></div>
  </div>
{{else if this.items.length}}
  <ul aria-labelledby={{@ariaLabelledby}}>
    {{#each this.items as |item|}}
      <UserMenu::MenuItem @item={{item}} @closeUserMenu={{@closeUserMenu}} />
    {{/each}}
  </ul>
  <div class="panel-body-bottom">
    {{#if this.showAllHref}}
      <DButton
        class="btn-default show-all"
        @href={{this.showAllHref}}
        @translatedAriaLabel={{this.showAllTitle}}
        @translatedTitle={{this.showAllTitle}}
      >
        {{d-icon "chevron-down" aria-label=this.showAllTitle}}
      </DButton>
    {{/if}}
    {{#if this.showDismiss}}
      <button
        type="button"
        class="btn btn-default notifications-dismiss btn-icon-text"
        title={{this.dismissTitle}}
        {{on "click" this.dismissButtonClick}}
      >
        {{d-icon "check"}}
        {{i18n "user.dismiss"}}
      </button>
    {{/if}}
    <PluginOutlet
      @name="panel-body-bottom"
      @outletArgs={{hash
        itemsCacheKey=this.itemsCacheKey
        closeUserMenu=@closeUserMenu
        showDismiss=this.showDismiss
        dismissButtonClick=this.dismissButtonClick
      }}
    />
  </div>
{{else}}
  <PluginOutlet
    @name="user-menu-items-list-empty-state"
    @outletArgs={{hash model=this}}
  >
    {{component this.emptyStateComponent}}
  </PluginOutlet>
{{/if}}
<PluginOutlet
  @name="after-panel-body"
  @outletArgs={{hash closeUserMenu=@closeUserMenu}}
/>
=======
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";

export default class UserMenuItemsList extends Component {
  @service session;

  @tracked loading = false;
  @tracked items = [];

  constructor() {
    super(...arguments);
    this.#load();
  }

  get itemsCacheKey() {}

  get showAllHref() {}

  get showAllTitle() {}

  get showDismiss() {
    return false;
  }

  get dismissTitle() {}

  get emptyStateComponent() {
    return "user-menu/items-list-empty-state";
  }

  get renderDismissConfirmation() {
    return false;
  }

  async fetchItems() {
    throw new Error(
      `the fetchItems method must be implemented in ${this.constructor.name}`
    );
  }

  async refreshList() {
    await this.#load();
  }

  async #load() {
    const cached = this.#getCachedItems();
    if (cached?.length) {
      this.items = cached;
    } else {
      this.loading = true;
    }
    try {
      const items = await this.fetchItems();
      this.#setCachedItems(items);
      this.items = items;
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error(
        `an error occurred when loading items for ${this.constructor.name}`,
        err
      );
    } finally {
      this.loading = false;
    }
  }

  #getCachedItems() {
    const key = this.itemsCacheKey;
    if (key) {
      return this.session[`user-menu-items:${key}`];
    }
  }

  #setCachedItems(newItems) {
    const key = this.itemsCacheKey;
    if (key) {
      this.session.set(`user-menu-items:${key}`, newItems);
    }
  }

  @action
  dismissButtonClick() {
    throw new Error(
      `dismissButtonClick must be implemented in ${this.constructor.name}.`
    );
  }
}
>>>>>>> a9ddbde3f6 (DEV: [gjs-codemod] renamed js to gjs)

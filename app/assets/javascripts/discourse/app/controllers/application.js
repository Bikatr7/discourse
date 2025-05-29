import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import runAfterFramePaint from "discourse/lib/after-frame-paint";
import discourseDebounce from "discourse/lib/debounce";
import discourseComputed from "discourse/lib/decorators";
import deprecated from "discourse/lib/deprecated";
import { isTesting } from "discourse/lib/environment";

const HIDE_SIDEBAR_KEY = "sidebar-hidden";

export default class ApplicationController extends Controller {
  @service router;
  @service footer;
  @service header;
  @service sidebarState;

  @tracked showSidebarIfEnabled = !this.keyValueStore.getItem(HIDE_SIDEBAR_KEY);

  queryParams = [{ navigationMenuQueryParamOverride: "navigation_menu" }];
  showTop = true;

  sidebarDisabledRouteOverride = false;
  navigationMenuQueryParamOverride = null;
  showSiteHeader = true;
  showSkipToContent = true;

  get showFooter() {
    return this.footer.showFooter;
  }

  set showFooter(value) {
    deprecated(
      "showFooter state is now stored in the `footer` service, and should be controlled by adding the {{hide-application-footer}} helper to an Ember template.",
      { id: "discourse.application-show-footer" }
    );
    this.footer.showFooter = value;
  }

  get showPoweredBy() {
    return this.showFooter && this.siteSettings.enable_powered_by_discourse;
  }

  @discourseComputed
  canSignUp() {
    return (
      !this.siteSettings.invite_only &&
      this.siteSettings.allow_new_registrations &&
      !this.siteSettings.enable_discourse_connect
    );
  }

  @discourseComputed
  canDisplaySidebar() {
    return this.currentUser || !this.siteSettings.login_required;
  }

  @discourseComputed
  loginRequired() {
    return this.siteSettings.login_required && !this.currentUser;
  }

  @discourseComputed
  showFooterNav() {
    return this.capabilities.isAppWebview || this.capabilities.isiOSPWA;
  }

  _mainOutletAnimate() {
    document.body.classList.remove("sidebar-animate");
  }

  get sidebarEnabled() {
    if (!this.canDisplaySidebar) {
      return false;
    }

    if (this.sidebarState.sidebarHidden) {
      return false;
    }

    if (this.sidebarDisabledRouteOverride) {
      return false;
    }

    // No sidebar for smaller viewports
    if (!this.capabilities.viewport.md) {
      return false;
    }

    if (this.navigationMenuQueryParamOverride === "sidebar") {
      return true;
    }

    if (this.navigationMenuQueryParamOverride === "header_dropdown") {
      return false;
    }

    // Always show sidebar for admin if user can see the admin sidebar
    if (this.sidebarState.isForcingSidebar) {
      return true;
    }

    return this.siteSettings.navigation_menu === "sidebar";
  }

  get showSidebar() {
    return this.sidebarEnabled && this.showSidebarIfEnabled;
  }

  @action
  toggleSidebar() {
    // enables CSS transitions, but not on did-insert
    document.body.classList.add("sidebar-animate");

    discourseDebounce(this, this._mainOutletAnimate, 250);

    this.showSidebarIfEnabled = !this.showSidebarIfEnabled;

    if (this.showSidebarIfEnabled) {
      this.keyValueStore.removeItem(HIDE_SIDEBAR_KEY);
    } else {
      this.keyValueStore.setItem(HIDE_SIDEBAR_KEY, "true");
    }
  }

  @action
  trackDiscoursePainted() {
    if (isTesting()) {
      return;
    }
    runAfterFramePaint(() => {
      performance.mark("discourse-paint");
      try {
        performance.measure(
          "discourse-init-to-paint",
          "discourse-init",
          "discourse-paint"
        );
      } catch (e) {
        // eslint-disable-next-line no-console
        console.warn("Failed to measure init-to-paint", e);
      }
    });
  }
}

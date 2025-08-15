# Firefox userChrome.css theme
# Using semantic color structure for better maintainability
{ ... }:
let
  colors = import ../../../lib/themes;
in
{
  # Simplified userChrome.css using Mozilla's color variable template
  userChromeCSS = ''
    /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/color_variable_template.css made available under Mozilla Public License v. 2.0
    See the above repository for updates as well as full license text. */

    /* You should enable any non-default theme for these to apply properly. Built-in dark and light themes should work */
    :root{
      /* Popup panels */
      --arrowpanel-background: ${colors.ui.background.secondary} !important;
      --arrowpanel-border-color: ${colors.ui.border.primary} !important;
      --arrowpanel-color: ${colors.ui.foreground.primary} !important;
      --arrowpanel-dimmed: rgba(0,0,0,0.4) !important;
      /* window and toolbar background */
      --lwt-accent-color: ${colors.ui.background.primary} !important;
      --lwt-accent-color-inactive: ${colors.ui.background.secondary} !important;
      --toolbar-bgcolor: rgba(0,0,0,0.4) !important;
      --tabpanel-background-color: ${colors.ui.background.secondary} !important;
      /* tabs with system theme - text is not controlled by variable */
      --tab-selected-bgcolor: ${colors.ui.background.tertiary} !important;
      /* tabs with any other theme */
      --lwt-text-color: ${colors.ui.foreground.primary} !important;
      --lwt-selected-tab-background-color: ${colors.ui.background.tertiary} !important;
      /* toolbar area */
      --toolbarbutton-icon-fill: ${colors.ui.foreground.primary} !important;
      --lwt-toolbarbutton-hover-background: ${colors.ui.special.hover} !important;
      --lwt-toolbarbutton-active-background: ${colors.ui.interactive.primary} !important;
      /* urlbar */
      --toolbar-field-border-color: ${colors.ui.background.primary} !important;
      --toolbar-field-focus-border-color: ${colors.ui.border.focus} !important;
      --urlbar-popup-url-color: ${colors.ui.interactive.muted} !important;
      /* urlbar Firefox < 92 */
      --lwt-toolbar-field-background-color: ${colors.ui.background.secondary} !important;
      --lwt-toolbar-field-focus: ${colors.ui.background.tertiary} !important;
      --lwt-toolbar-field-color: ${colors.ui.foreground.primary} !important;
      --lwt-toolbar-field-focus-color: ${colors.ui.foreground.primary} !important;
      /* urlbar Firefox 92+ */
      --toolbar-field-background-color: ${colors.ui.background.primary} !important;
      --toolbar-field-focus-background-color: ${colors.ui.background.tertiary} !important;
      --toolbar-field-color: ${colors.ui.foreground.primary} !important;
      --toolbar-field-focus-color: ${colors.ui.foreground.primary} !important;
      /* sidebar - note the sidebar-box rule for the header-area */
      --lwt-sidebar-background-color: ${colors.ui.background.primary} !important;
      --lwt-sidebar-text-color: ${colors.ui.foreground.primary} !important;
    }
    /* line between nav-bar and tabs toolbar,
    also fallback color for border-top of nav-bar if there are no tabs */
    #navigator-toolbox{ --lwt-tabs-border-color: ${colors.ui.border.primary} !important; }
    /* active tab line */
    #tabbrowser-tabs{ --lwt-tab-line-color: ${colors.ui.foreground.primary} !important; }
    /* sidebar header */
    #sidebar-box{ --sidebar-background-color: ${colors.ui.background.primary} !important; }

    /* Navigation toolbar background */
    #nav-bar {
      background-color: ${colors.ui.background.primary} !important;
    }

    /* Vertical tabs sidebar footer background */
    #sidebar-box #sidebar-main vbox > box:last-child {
      background-color: ${colors.ui.background.primary} !important;
    }

    /* URL bar background and border styling */
    #urlbar, #urlbar-background {
      background-color: ${colors.ui.background.primary} !important;
      border: 1px solid ${colors.ui.background.primary} !important;
    }

    /* Comprehensive menu and popup styling */
    menupopup, panel, #downloadsPanel, #identity-popup, #permission-popup,
    #protections-popup, #appMenu-popup, #PanelUI-popup, .panel-arrowcontent,
    #contentAreaContextMenu, #toolbar-context-menu, #placesContext,
    #SyncedTabsSidebar, #sidebar, #sidebar-header {
      --menu-color: ${colors.ui.foreground.primary} !important;
      --arrowpanel-color: ${colors.ui.foreground.primary} !important;
      --panel-color: ${colors.ui.foreground.primary} !important;
      --menu-background-color: ${colors.ui.background.secondary} !important;
      --arrowpanel-background: ${colors.ui.background.secondary} !important;
      --panel-background: ${colors.ui.background.secondary} !important;
      --menu-border-color: ${colors.ui.border.primary} !important;
      --arrowpanel-border-color: ${colors.ui.border.primary} !important;
      --panel-border-color: ${colors.ui.background.primary} !important;
      --menuitem-hover-background-color: ${colors.ui.special.hover} !important;
      --button-hover-bgcolor: ${colors.ui.special.hover} !important;
    }

    /* Force sidebar background - override any GTK interference */
    #sidebar, #sidebar-box, #sidebar-main, #sidebar-splitter + #sidebar-box,
    vbox[id="sidebar-box"], #sidebar > *, .sidebar-panel {
      background-color: ${colors.ui.background.primary} !important;
      background: ${colors.ui.background.primary} !important;
    }
  '';
}

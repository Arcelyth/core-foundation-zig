const c = @import("c");

pub const Orientation = enum(u32) {
    default = 0,
    horizontal = 1,
    vertical = 2,
};

pub const Options = packed struct(usize) {
    prevent_auto_activation: bool = false,
    prevent_auto_download: bool = false,
    prefer_system_font: bool = false,
    _reserved: @Int(.unsigned, @bitSizeOf(usize) - 3) = 0,
};

pub const UiFontType = enum(u32) {
    none = 0xffffffff,
    user = 0,
    user_fixed_pitch = 1,
    system = 2,
    emphasized_system = 3,
    small_system = 4,
    small_emphasized_system = 5,
    mini_system = 6,
    mini_emphasized_system = 7,
    views = 8,
    application = 9,
    label = 10,
    menu_title = 11,
    menu_item = 12,
    menu_item_mark = 13,
    menu_item_cmd_key = 14,
    window_title = 15,
    push_button = 16,
    utility_window_title = 17,
    alert_header = 18,
    system_detail = 19,
    emphasized_system_detail = 20,
    toolbar = 21,
    small_toolbar = 22,
    message = 23,
    palette = 24,
    tool_tip = 25,
    control_content = 26,
    _,
};

pub const SymbolicTraits = packed struct(u32) {
    italic: bool = false,
    bold: bool = false,
    _reserved2: u3 = 0,
    expanded: bool = false,
    condensed: bool = false,
    _reserved7: u3 = 0,
    mono_space: bool = false,
    vertical: bool = false,
    ui_optimized: bool = false,
    color_glyphs: bool = false,
    composite: bool = false,
    _reserved15: u13 = 0,
    stylistic_class: u4 = 0,
};

pub const TableTag = c.CTFontTableTag;
pub const TableOptions = u32;

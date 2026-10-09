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

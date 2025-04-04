function hexColorRule(state, silent) {
  const start = state.pos;
  const max = state.posMax;
  const src = state.src;
  const firstChar = src.charCodeAt(start);

  // early exit if first char isn't `#`
  // or there's less than 7 characters left
  if (firstChar !== 0x23 || start + 4 > max) {
    return false;
  }

  if (start > 0) {
    const prevChar = src.charAt(start - 1);
    const isAllowed = /\s/.test(prevChar) || /[([{<]/.test(prevChar);
    if (!isAllowed) {
      return false;
    }
  }

  const match = src
    .slice(start)
    .match(/^#(?:[0-9A-Fa-f]{3,4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})(?=\b|_|$)/i);

  if (!match) {
    return false;
  }

  if (!silent) {
    const token = state.push("hex_color", "", 0);
    token.content = match[0];
  }

  state.pos += match[0].length;

  return true;
}

function hexColorRender(tokens, idx) {
  const color = tokens[idx].content;
  return `<span class="hex-color"><span class="hex-color__swatch" style="--swatch-color: ${color};"></span>${color.toUpperCase()}</span>`;
}

export function setup(helper) {
  helper.allowList(["span.hex-color__swatch", "span.hex-color"]);

  helper.allowList({
    custom(tag, name, value) {
      if (tag === "span" && name === "style") {
        const pattern = /^--swatch-color:\s?#[a-f0-9]{3,8};$/;
        return pattern.test(value.toLowerCase());
      }
      return false;
    },
  });

  helper.registerOptions(() => {
    return {
      features: {
        "hex-color": true,
      },
    };
  });

  helper.registerPlugin((md) => {
    md.inline.ruler.push("hex_color", hexColorRule);
    md.renderer.rules["hex_color"] = hexColorRender;
  });
}

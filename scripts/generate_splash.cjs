// Source assets only: does not build, sign, install or launch the application.
const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');
const app = path.resolve(__dirname, '..');

async function generate() {
  const catalog = path.join(app, 'ios/Runner/Assets.xcassets/LaunchImage.imageset');
  const images = [];
  for (const dark of [false, true]) {
    const source = path.join(app, `assets/brand/splash-${dark ? 'dark' : 'light'}.svg`);
    for (const scale of [1, 2, 3]) {
      const filename = `LaunchImage${dark ? '-dark' : ''}${scale === 1 ? '' : `@${scale}x`}.png`;
      await sharp(source).resize(112 * scale, 112 * scale).png().toFile(path.join(catalog, filename));
      images.push({ idiom: 'universal', filename, scale: `${scale}x`,
        ...(dark ? { appearances: [{ appearance: 'luminosity', value: 'dark' }] } : {}) });
    }
    const res = path.join(app, 'android/app/src/main/res');
    const masked = path.join(res, `drawable${dark ? '-night' : ''}-nodpi`);
    await fs.mkdir(masked, { recursive: true });
    await sharp(source).resize(144, 144).extend({ top: 72, bottom: 72, left: 72, right: 72, background: '#00000000' })
      .png().toFile(path.join(masked, 'launch_mark.png'));
    // Legacy Android uses a real 112dp emblem rather than a density-independent bitmap.
    for (const [density, factor] of [['mdpi', 1], ['hdpi', 1.5], ['xhdpi', 2], ['xxhdpi', 3], ['xxxhdpi', 4]]) {
      const dir = path.join(res, `drawable${dark ? '-night' : ''}-${density}`);
      await fs.mkdir(dir, { recursive: true });
      await sharp(source).resize(112 * factor, 112 * factor).png().toFile(path.join(dir, 'launch_mark_legacy.png'));
    }
  }
  await fs.writeFile(path.join(catalog, 'Contents.json'), JSON.stringify({ images, info: { version: 1, author: 'xcode' } }, null, 2) + '\n');
}
generate().catch(error => { console.error(error.message); process.exitCode = 1; });

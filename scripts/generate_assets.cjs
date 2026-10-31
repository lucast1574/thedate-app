const fs=require('node:fs'), path=require('node:path'), cp=require('node:child_process');
const sharp=require(process.env.DATE_SHARP_MODULE || 'sharp');
const root=path.resolve(__dirname,'..'), wedding=path.basename(root)==='save-the-date-app';
const brand=path.join(root,'assets/brand'),store=path.join(root,'store/es-419');
const paper=wedding?'#faf6f0':'#fff9ed', ink=wedding?'#302720':'#241638';
async function raster(svg,name,background){
 const mark=await sharp(Buffer.from(svg)).resize(700,700).png().toBuffer();
 await sharp({create:{width:1024,height:1024,channels:4,background}})
   .composite([{input:mark,gravity:'centre'}]).png().toFile(path.join(brand,name));
}
(async()=>{
 const svg=fs.readFileSync(path.join(brand,'mark.svg'),'utf8');
 await raster(svg,'foreground.png','#00000000');
 await raster(svg.replace(/#[a-f0-9]{6}/gi,'#ffffff'),'monochrome.png','#00000000');
 await raster(svg,'app-icon.png',paper);
 await sharp(path.join(brand,'app-icon.png')).resize(512,512).png().toFile(path.join(store,'icon.png'));
 cp.execFileSync('convert',['-size','1024x500','xc:'+paper,'-font',path.join(root,'assets/fonts',wedding?'CormorantGaramond[wght].ttf':'Nunito[wght].ttf'),'-fill',ink,'-gravity','NorthWest','-pointsize','64','-annotate','+64+140',wedding?'Save the Date':'The Date','-pointsize','34','-annotate','+64+238',wedding?'Vuestra boda, en calma.':'Tu celebración, a mano.','-font',path.join(root,'assets/fonts/DMSans[opsz,wght].ttf'),'-pointsize','24','-annotate','+64+320','Confirmaciones · Regalos · Cuenta','(',path.join(brand,'foreground.png'),'-resize','280x280',')','-gravity','East','-geometry','+32+0','-composite',path.join(store,'feature-graphic.png')]);
 console.log('Generated launcher and store artwork from the official brand vector.');
})().catch(e=>{console.error(e);process.exitCode=1});

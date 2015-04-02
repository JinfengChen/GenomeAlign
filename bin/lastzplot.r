pdf("./4r.pdf");
dots=read.table("./4r",header=T);
plot(dots,type="l");
dev.off();

/* statisticke funkcie */
SELECT load_extension('./libsqlitefunctions.so');

/* iba vysledky pri posielani zo servera */
CREATE TEMPORARY TABLE results_server AS SELECT cipher, digest, compress, data_file, duration FROM results WHERE sender="server";

/* pomocny view pre porovnanie kompresie */
CREATE TEMPORARY TABLE compress_relative AS SELECT DISTINCT v1.cipher as cipher, v1.digest as digest, v1.data_file as data_file, v1.duration as comp0_duration, v2.duration as comp1_duration, v2.duration / v1.duration as delta FROM results_server v1 JOIN results_server v2 ON v1.cipher = v2.cipher AND v1.digest = v2.digest AND v1.data_file=v2.data_file WHERE v1.compress=0 AND v2.compress=1;

/* pomocne tabulky pre porovnanie sifier a digestov */
CREATE TEMPORARY TABLE cip_dig_tt AS SELECT cipher, digest, duration FROM results_server WHERE data_file="random" AND compress=0 ORDER BY digest, duration;

CREATE TEMPORARY TABLE cipher_speedup AS SELECT *, duration / (SELECT MIN(duration) FROM cip_dig_tt cd2 WHERE cd2.digest=cd1.digest GROUP BY digest) as relative_duration FROM cip_dig_tt cd1;
CREATE TEMPORARY TABLE digest_speedup AS SELECT *, duration / (SELECT duration FROM cip_dig_tt cd2 WHERE cd2.cipher=cd1.cipher AND digest="MD4") as relative_duration FROM cip_dig_tt cd1;

/* vypis vysledkov */
.mode column
.width 16 8 8 8 8 8
.echo ON
/* porovnanie kompresie */
SELECT data_file, ROUND(AVG(delta), 4), ROUND(STDEV(delta), 4), ROUND(MEDIAN(delta), 4), ROUND(MIN(delta), 4), ROUND(MAX(delta), 4) FROM compress_relative GROUP BY data_file;

/* porovnanie sifier */
SELECT cipher, ROUND(AVG(relative_duration), 4), ROUND(STDEV(relative_duration),4), ROUND(MEDIAN(relative_duration), 4), ROUND(MIN(relative_duration), 4), ROUND(MAX(relative_duration), 4) FROM cipher_speedup GROUP BY cipher ORDER BY AVG(relative_duration);

/* porovnanie digestov */
SELECT digest, ROUND(AVG(relative_duration), 4), ROUND(STDEV(relative_duration),4), ROUND(MEDIAN(relative_duration), 4), ROUND(MIN(relative_duration), 4), ROUND(MAX(relative_duration), 4) FROM digest_speedup GROUP BY digest ORDER BY AVG(relative_duration);

/* zoradenie dvojic sifra-digest podla relativneho casu */
.width 16 16 8
/* relativny cas bez OpenVPN */
SELECT ROUND(2.85148714925/MIN(duration), 4) FROM cip_dig_tt;
SELECT cipher, digest, ROUND(duration/(SELECT MIN(duration) FROM cip_dig_tt), 4) FROM cip_dig_tt ORDER BY duration ASC LIMIT 15;
SELECT cipher, digest, ROUND(duration/(SELECT MIN(duration) FROM cip_dig_tt), 4) FROM cip_dig_tt ORDER BY duration ASC LIMIT 390,10;

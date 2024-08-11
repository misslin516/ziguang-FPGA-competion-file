//created date:2024/7/19
//Note:由于牛顿迭代算法本身带来的误差，除了比较商还要考虑余数,这里暂时没有考虑，采用扩大分子来消除这一影响
//Only 40clk can be done
//This code is function test for auido_recognization
module auido_recognization_top
#(
    parameter   Dlength = 'd192
)
(
    input          sys_clk                 ,
    input          sys_rst_n               ,
                                       
    input  signed [15:0] feature_in        ,
    input          feature_in_en           ,
                                    
    output  reg[3:0] compare_result        ,
    output  reg      compare_result_v1
);

/***********************para*********************************/
//This parameters come from python included every speaker's feature
parameter signed [15:0] feature_user1 [0:191] = {
    -16'sd3010, 16'sd1056, 16'sd1831, 16'sd2111, 16'sd3008, -16'sd2240, 16'sd7329, 16'sd1830, -16'sd4449, 16'sd482, 
    16'sd8184, 16'sd11398, -16'sd5006, 16'sd3625, 16'sd789, 16'sd5458, 16'sd3179, -16'sd157, -16'sd5017, 16'sd1079, 
    16'sd16202, 16'sd924, 16'sd6592, 16'sd1554, -16'sd3183, 16'sd877, 16'sd1036, -16'sd1540, -16'sd5979, 16'sd6519, 
    16'sd8840, -16'sd1698, -16'sd3856, 16'sd145, 16'sd1012, -16'sd4063, 16'sd992, -16'sd1157, -16'sd7270, -16'sd4409, 
    -16'sd4396, 16'sd3754, -16'sd911, 16'sd1802, -16'sd214, 16'sd563, -16'sd5521, 16'sd5681, -16'sd712, -16'sd4341, 
    16'sd422, -16'sd1541, 16'sd4571, 16'sd11394, -16'sd3731, -16'sd8845, 16'sd795, -16'sd6613, 16'sd336, -16'sd1548, 
    16'sd1434, 16'sd7761, -16'sd101, -16'sd1360, 16'sd8071, 16'sd6304, 16'sd6989, 16'sd6447, -16'sd14514, 16'sd1994, 
    16'sd1707, 16'sd3677, 16'sd3087, -16'sd2643, 16'sd7549, -16'sd6462, -16'sd2972, -16'sd1547, -16'sd251, 16'sd2255, 
    16'sd3507, 16'sd1536, 16'sd715, 16'sd442, -16'sd9926, 16'sd1476, 16'sd2741, -16'sd6470, 16'sd6824, 16'sd2341, 
    16'sd2921, -16'sd4608, 16'sd15287, -16'sd2659, 16'sd1722, 16'sd2538, 16'sd3951, -16'sd3285, -16'sd8302, -16'sd4446, 
    16'sd1075, 16'sd3105, -16'sd354, 16'sd10938, 16'sd6615, -16'sd2783, 16'sd6011, -16'sd3748, -16'sd1092, -16'sd5322, 
    16'sd3981, -16'sd98, -16'sd5783, 16'sd2128, 16'sd9736, -16'sd3918, -16'sd8021, -16'sd1370, -16'sd3257, -16'sd3629, 
    16'sd3974, -16'sd2049, -16'sd10537, -16'sd5456, -16'sd2122, 16'sd2656, 16'sd2651, 16'sd5502, 16'sd351, 16'sd4184, 
    -16'sd4551, 16'sd1776, 16'sd3580, -16'sd9472, 16'sd2613, 16'sd2515, 16'sd184, -16'sd9093, -16'sd9168, -16'sd396, 
    -16'sd5698, 16'sd1375, 16'sd2254, -16'sd10226, 16'sd1097, -16'sd13745, -16'sd1544, 16'sd4909, -16'sd2501, -16'sd4422, 
    16'sd5305, -16'sd6479, -16'sd3726, 16'sd3113, -16'sd5616, -16'sd7506, 16'sd8123, -16'sd2499, -16'sd441, 16'sd4639, 
    -16'sd3448, 16'sd80, -16'sd8041, 16'sd8731, -16'sd2226, 16'sd1400, -16'sd14313, -16'sd633, -16'sd1091, 16'sd9315, 
    -16'sd4496, 16'sd5325, 16'sd8087, -16'sd136, 16'sd1125, -16'sd8549, 16'sd3682, 16'sd3245, 16'sd5021, 16'sd5174, 
    16'sd4012, 16'sd5907, 16'sd10613, -16'sd3661, -16'sd5192, -16'sd4876, -16'sd5022, -16'sd1938, -16'sd3366, 16'sd1854, 
    -16'sd5955, 16'sd1598
};

parameter signed [15:0] feature_user2 [0:191] = {
    16'sd1859, 16'sd4040, -16'sd2059, 16'sd1980, 16'sd9873, -16'sd5299, -16'sd1737, 16'sd3118, -16'sd12167, 16'sd6503, 
    16'sd1830, 16'sd6322, -16'sd5051, -16'sd2550, 16'sd6124, 16'sd3072, -16'sd677, 16'sd3946, 16'sd1359, 16'sd1817, 
    16'sd10426, 16'sd4700, 16'sd5137, 16'sd603, 16'sd3663, 16'sd2394, -16'sd5705, 16'sd809, -16'sd4821, 16'sd9107, 
    16'sd10096, -16'sd2888, -16'sd4012, -16'sd5439, 16'sd1418, -16'sd4975, 16'sd2465, 16'sd3813, -16'sd3585, 16'sd731, 
    -16'sd7099, -16'sd6227, -16'sd474, 16'sd5162, 16'sd6143, -16'sd460, -16'sd1778, 16'sd6906, -16'sd1400, -16'sd2743, 
    -16'sd1617, 16'sd4164, 16'sd6779, 16'sd13186, -16'sd2892, -16'sd3719, 16'sd5357, -16'sd7644, -16'sd9384, -16'sd5514, 
    -16'sd7190, 16'sd10228, -16'sd3161, 16'sd3733, 16'sd13171, -16'sd1820, 16'sd7105, -16'sd4359, -16'sd14920, -16'sd2416, 
    -16'sd1458, -16'sd229, -16'sd1760, -16'sd8227, 16'sd10981, -16'sd3336, -16'sd4351, -16'sd5642, 16'sd4553, 16'sd2376, 
    16'sd10057, 16'sd1450, -16'sd1341, 16'sd2460, -16'sd6998, 16'sd2963, 16'sd3691, -16'sd2303, 16'sd6872, 16'sd9322, 
    16'sd2015, -16'sd608, 16'sd13824, 16'sd4604, -16'sd137, -16'sd2934, 16'sd2048, -16'sd3715, -16'sd7735, -16'sd4804, 
    16'sd1273, 16'sd8733, 16'sd5573, 16'sd12426, 16'sd597, 16'sd389, 16'sd15305, -16'sd5620, -16'sd4038, -16'sd1586, 
    -16'sd4122, 16'sd8732, -16'sd323, 16'sd3960, 16'sd6671, -16'sd2030, -16'sd6401, -16'sd3474, -16'sd5309, -16'sd1770, 
    16'sd5756, -16'sd9209, -16'sd14136, -16'sd7966, 16'sd1441, 16'sd786, 16'sd2237, 16'sd5247, -16'sd1650, 16'sd11472, 
    -16'sd1314, 16'sd4639, 16'sd5552, -16'sd12272, -16'sd1483, -16'sd2020, 16'sd7430, -16'sd6700, -16'sd6517, 16'sd4663, 
    -16'sd3333, -16'sd4943, -16'sd461, -16'sd15231, 16'sd1631, -16'sd5850, -16'sd3243, 16'sd6079, -16'sd7295, -16'sd2735, 
    16'sd4388, -16'sd6110, -16'sd923, 16'sd6639, -16'sd8438, -16'sd4396, 16'sd3052, 16'sd1119, 16'sd2585, 16'sd4689, 
    -16'sd2476, 16'sd1304, -16'sd9921, 16'sd7225, -16'sd7402, 16'sd1656, -16'sd10213, 16'sd1830, -16'sd5142, 16'sd7698, 
    -16'sd6541, 16'sd3435, 16'sd7703, -16'sd2071, -16'sd2483, -16'sd6778, 16'sd4171, -16'sd5852, -16'sd1038, 16'sd12899, 
    -16'sd3432, -16'sd2779, 16'sd10535, -16'sd4913, 16'sd2251, -16'sd481, -16'sd9097, -16'sd2350, -16'sd9065, -16'sd1186, 
    -16'sd4502, -16'sd3988
};

parameter signed [15:0] feature_user3 [0:191] = {
    16'sd3837, 16'sd1662, 16'sd2444, 16'sd4923, 16'sd6633, -16'sd3996, -16'sd2075, 16'sd5071, -16'sd10095, 16'sd5318, 
    -16'sd448, 16'sd14301, -16'sd3683, -16'sd1998, 16'sd6040, 16'sd2892, 16'sd3873, 16'sd3016, -16'sd1294, 16'sd5378, 
    16'sd13299, 16'sd2424, 16'sd5289, 16'sd3888, 16'sd3377, -16'sd3788, -16'sd6587, -16'sd3326, -16'sd6147, 16'sd7156, 
    16'sd9246, -16'sd3300, -16'sd2245, -16'sd6744, 16'sd173, -16'sd2272, 16'sd714, 16'sd938, -16'sd8457, -16'sd7163, 
    -16'sd2784, -16'sd4118, 16'sd940, 16'sd3404, 16'sd5054, -16'sd2410, -16'sd526, 16'sd10019, -16'sd4498, -16'sd4862, 
    16'sd3480, 16'sd1029, 16'sd2682, 16'sd13241, -16'sd2000, -16'sd6180, 16'sd6228, -16'sd5647, 16'sd341, -16'sd7305, 
    -16'sd3556, 16'sd2895, 16'sd187, 16'sd3724, 16'sd8406, 16'sd6301, 16'sd5451, 16'sd428, -16'sd10128, -16'sd201, 
    16'sd136, 16'sd1945, 16'sd1670, -16'sd2939, 16'sd6673, -16'sd5384, -16'sd2027, -16'sd9287, 16'sd6077, 16'sd224, 
    16'sd8962, 16'sd2995, 16'sd3341, 16'sd1236, -16'sd5203, -16'sd812, -16'sd2068, -16'sd4242, 16'sd5686, 16'sd7718, 
    16'sd9183, -16'sd205, 16'sd13119, 16'sd890, 16'sd4249, -16'sd968, 16'sd4143, -16'sd3538, -16'sd1677, -16'sd2177, 
    16'sd1290, 16'sd3178, 16'sd702, 16'sd8894, 16'sd999, -16'sd1915, 16'sd4489, -16'sd5586, 16'sd2640, -16'sd525, 
    16'sd1639, 16'sd9488, 16'sd1153, 16'sd2015, 16'sd9210, -16'sd4698, -16'sd12384, -16'sd3296, -16'sd4600, -16'sd1612, 
    16'sd4877, -16'sd3760, -16'sd14898, -16'sd11260, 16'sd521, 16'sd3205, 16'sd1947, 16'sd141, -16'sd3479, 16'sd10942, 
    -16'sd1105, 16'sd3785, 16'sd3171, -16'sd6641, -16'sd3352, -16'sd1363, 16'sd5749, -16'sd8785, -16'sd3897, 16'sd277, 
    -16'sd4088, -16'sd3275, -16'sd466, -16'sd12393, 16'sd3629, -16'sd4245, -16'sd1572, 16'sd3635, -16'sd7165, -16'sd930, 
    16'sd5785, -16'sd5742, -16'sd958, 16'sd7221, -16'sd2601, -16'sd3510, 16'sd7153, -16'sd1281, 16'sd1017, 16'sd5642, 
    16'sd1981, -16'sd3273, -16'sd9130, 16'sd1665, -16'sd6302, 16'sd3798, -16'sd7976, -16'sd1509, -16'sd3203, 16'sd3671, 
    -16'sd2072, 16'sd6495, 16'sd9031, 16'sd1754, -16'sd1607, -16'sd11586, 16'sd6198, -16'sd7649, 16'sd3111, 16'sd10581, 
    -16'sd948, 16'sd1634, 16'sd7190, -16'sd7846, -16'sd2699, 16'sd295, -16'sd7049, -16'sd4789, -16'sd6897, 16'sd1213, 
    -16'sd2229, 16'sd1625
};

parameter signed [15:0] feature_user4 [0:191] = {
    16'sd2410, 16'sd3511, 16'sd5821, 16'sd5332, 16'sd4879, 16'sd115, 16'sd2070, 16'sd5649, -16'sd8600, -16'sd38, 
    16'sd4250, 16'sd12700, -16'sd2674, 16'sd5323, -16'sd304, 16'sd2082, -16'sd446, 16'sd1123, -16'sd5952, 16'sd7730, 
    16'sd12291, -16'sd748, 16'sd7882, 16'sd9024, 16'sd655, -16'sd7299, -16'sd112, 16'sd585, -16'sd7382, 16'sd14037, 
    16'sd7052, -16'sd2779, -16'sd6352, -16'sd10035, 16'sd6229, 16'sd67, -16'sd1393, 16'sd2485, -16'sd5298, -16'sd5790, 
    -16'sd3285, -16'sd2959, -16'sd654, 16'sd310, -16'sd1558, 16'sd2850, -16'sd4107, 16'sd5198, 16'sd737, -16'sd4068, 
    16'sd1210, 16'sd222, 16'sd4881, 16'sd6066, 16'sd855, -16'sd11682, -16'sd546, -16'sd6500, 16'sd3138, -16'sd3384, 
    16'sd4626, 16'sd5173, 16'sd1156, 16'sd2635, 16'sd6841, 16'sd4729, 16'sd8905, 16'sd5458, -16'sd14595, -16'sd1033, 
    16'sd764, 16'sd700, 16'sd1162, -16'sd5100, 16'sd12912, -16'sd5267, -16'sd2444, -16'sd5554, 16'sd2823, 16'sd1688, 
    16'sd10344, 16'sd2625, 16'sd9179, 16'sd1815, -16'sd6297, -16'sd157, -16'sd2094, -16'sd8370, 16'sd7746, 16'sd6687, 
    16'sd5112, 16'sd2640, 16'sd9450, -16'sd3871, 16'sd7181, -16'sd146, 16'sd2460, -16'sd5601, 16'sd2118, 16'sd1890, 
    16'sd3381, 16'sd5750, 16'sd3628, 16'sd7094, -16'sd396, -16'sd7167, 16'sd2553, -16'sd6409, 16'sd908, 16'sd1015, 
    16'sd3445, 16'sd4352, -16'sd2574, -16'sd808, 16'sd7467, -16'sd1841, -16'sd6915, -16'sd6579, 16'sd272, 16'sd2183, 
    16'sd6668, 16'sd1258, -16'sd13118, -16'sd5137, -16'sd2686, 16'sd2580, 16'sd3383, 16'sd5034, 16'sd853, 16'sd4786, 
    -16'sd4888, 16'sd4647, -16'sd25, -16'sd5739, -16'sd3348, 16'sd6699, -16'sd3162, -16'sd10655, -16'sd862, 16'sd1681, 
    -16'sd3726, -16'sd30, 16'sd3838, -16'sd8415, -16'sd1862, -16'sd7409, -16'sd5181, 16'sd718, -16'sd4090, -16'sd1284, 
    16'sd12407, -16'sd6833, 16'sd1031, 16'sd3866, -16'sd5621, -16'sd10662, 16'sd11151, -16'sd1343, -16'sd2427, -16'sd464, 
    -16'sd318, 16'sd41, -16'sd8013, 16'sd1320, -16'sd1812, 16'sd6424, -16'sd7246, 16'sd6506, 16'sd587, 16'sd5861, 
    16'sd129, 16'sd9836, 16'sd7548, 16'sd4749, -16'sd497, -16'sd12704, 16'sd5954, -16'sd7786, 16'sd3093, 16'sd10362, 
    16'sd425, 16'sd7717, 16'sd11162, -16'sd6112, -16'sd6197, -16'sd4932, -16'sd4100, -16'sd4335, -16'sd4270, 16'sd4747, 
    -16'sd3388, 16'sd1762
};

parameter signed [15:0] feature_user5 [0:191] = {
    -16'sd163, 16'sd993, 16'sd744, 16'sd1648, 16'sd1941, 16'sd1912, -16'sd1599, 16'sd7966, -16'sd9097, 16'sd3327, 
    16'sd705, 16'sd7389, -16'sd1643, 16'sd36, 16'sd3950, 16'sd5862, -16'sd1009, -16'sd1423, -16'sd5036, 16'sd2327, 
    16'sd13765, 16'sd268, 16'sd7811, 16'sd4711, 16'sd1234, 16'sd845, 16'sd402, 16'sd6797, -16'sd6699, 16'sd5847, 
    16'sd11345, -16'sd5114, -16'sd5268, -16'sd2218, 16'sd3841, -16'sd1764, 16'sd1516, 16'sd1318, -16'sd4911, -16'sd3436, 
    -16'sd8633, -16'sd4466, -16'sd1005, 16'sd4113, 16'sd1059, 16'sd1394, -16'sd2981, 16'sd6391, 16'sd1838, -16'sd3410, 
    -16'sd2955, 16'sd2173, 16'sd5998, 16'sd5503, 16'sd1692, -16'sd10308, 16'sd3397, -16'sd8544, -16'sd2310, -16'sd4093, 
    -16'sd1733, 16'sd6350, -16'sd955, -16'sd809, 16'sd7516, 16'sd2675, 16'sd9071, 16'sd3868, -16'sd12722, 16'sd3513, 
    -16'sd952, 16'sd2301, 16'sd2208, -16'sd3824, 16'sd6241, -16'sd6165, -16'sd1365, -16'sd3047, -16'sd2755, 16'sd202, 
    16'sd7536, -16'sd2268, 16'sd1475, -16'sd481, -16'sd8858, 16'sd2315, 16'sd1489, -16'sd3423, 16'sd11979, 16'sd7512, 
    16'sd4122, 16'sd4145, 16'sd9929, -16'sd755, 16'sd379, 16'sd2576, 16'sd4190, -16'sd376, -16'sd4996, 16'sd193, 
    16'sd1585, 16'sd12100, 16'sd4427, 16'sd13198, 16'sd1182, -16'sd73, 16'sd11077, -16'sd4262, -16'sd3327, -16'sd329, 
    16'sd1447, 16'sd3276, 16'sd1341, -16'sd1314, 16'sd1254, -16'sd3514, -16'sd9200, -16'sd235, 16'sd522, 16'sd3667, 
    16'sd4991, -16'sd5991, -16'sd18656, 16'sd573, -16'sd1749, 16'sd832, 16'sd4284, 16'sd7297, 16'sd168, 16'sd8420, 
    -16'sd3238, 16'sd2203, 16'sd1964, -16'sd11137, 16'sd4359, 16'sd2767, 16'sd675, -16'sd3487, -16'sd8270, 16'sd2336, 
    -16'sd4953, -16'sd1930, 16'sd4153, -16'sd9537, 16'sd4194, -16'sd9549, -16'sd6095, 16'sd3551, -16'sd8920, -16'sd5229, 
    16'sd10634, -16'sd8796, -16'sd2591, -16'sd682, -16'sd5547, -16'sd11242, 16'sd6056, 16'sd4922, -16'sd64, 16'sd761, 
    -16'sd779, -16'sd3048, -16'sd7750, 16'sd3458, -16'sd2484, 16'sd1978, -16'sd12532, 16'sd4008, -16'sd1034, 16'sd11548, 
    -16'sd4680, 16'sd7988, 16'sd11227, -16'sd3278, 16'sd3170, -16'sd10704, 16'sd10047, -16'sd1928, 16'sd2213, 16'sd10606, 
    -16'sd4513, -16'sd406, 16'sd9089, -16'sd4473, 16'sd1127, -16'sd4330, -16'sd4014, -16'sd6704, -16'sd2464, -16'sd1122, 
    -16'sd7888, -16'sd1362
};
parameter signed [15:0] feature_user6 [0:191] = {
    16'sd1201, 16'sd1191, 16'sd464, 16'sd7581, 16'sd6579, -16'sd1348, -16'sd3121, 16'sd5963, -16'sd10351, 16'sd3861, 
    16'sd5086, 16'sd15023, -16'sd141, -16'sd3843, 16'sd6150, 16'sd3353, 16'sd129, -16'sd1504, -16'sd8514, 16'sd4858, 
    16'sd12517, 16'sd1822, 16'sd6331, 16'sd2622, 16'sd3168, -16'sd710, -16'sd2890, 16'sd6513, -16'sd6811, 16'sd11130, 
    16'sd11004, -16'sd8908, -16'sd2789, -16'sd629, 16'sd1305, -16'sd5710, -16'sd1529, -16'sd1997, -16'sd5746, -16'sd7345, 
    -16'sd3005, -16'sd2730, -16'sd549, 16'sd5230, 16'sd4524, -16'sd4005, 16'sd174, 16'sd8496, -16'sd30, -16'sd4369, 
    -16'sd2063, 16'sd2483, 16'sd5050, 16'sd12004, 16'sd446, -16'sd10178, 16'sd1826, -16'sd11457, -16'sd1498, -16'sd2725, 
    16'sd2176, 16'sd15137, -16'sd1209, 16'sd2436, 16'sd8635, 16'sd3391, 16'sd9273, 16'sd1842, -16'sd17775, -16'sd100, 
    -16'sd2417, -16'sd811, 16'sd3315, -16'sd2798, 16'sd8635, -16'sd5621, -16'sd2483, -16'sd5605, 16'sd5116, -16'sd2040, 
    16'sd14166, 16'sd18, 16'sd621, 16'sd884, -16'sd9888, 16'sd929, 16'sd3615, -16'sd5527, 16'sd13845, 16'sd9307, 
    16'sd3780, 16'sd1063, 16'sd12884, -16'sd3030, 16'sd18, -16'sd894, 16'sd5179, -16'sd4861, -16'sd8680, -16'sd1667, 
    16'sd108, 16'sd8584, 16'sd5747, 16'sd17156, 16'sd1893, -16'sd1859, 16'sd8900, -16'sd6765, -16'sd1259, -16'sd1200, 
    -16'sd227, 16'sd4941, -16'sd100, -16'sd949, 16'sd6931, -16'sd4484, -16'sd9773, -16'sd5302, -16'sd4551, 16'sd307, 
    16'sd6533, -16'sd438, -16'sd18161, -16'sd9423, 16'sd1579, 16'sd568, 16'sd4527, 16'sd1745, -16'sd1886, 16'sd13427, 
    -16'sd5120, 16'sd7020, 16'sd1508, -16'sd12258, 16'sd2132, 16'sd4931, 16'sd3160, -16'sd7724, -16'sd10215, 16'sd1584, 
    -16'sd4811, -16'sd5655, 16'sd1652, -16'sd11373, 16'sd2247, -16'sd11797, -16'sd4767, 16'sd6381, -16'sd3024, -16'sd4994, 
    16'sd11271, -16'sd8361, -16'sd2066, 16'sd2878, -16'sd4268, -16'sd11774, 16'sd3935, 16'sd724, 16'sd2529, 16'sd1025, 
    -16'sd1619, -16'sd1724, -16'sd12266, 16'sd4312, -16'sd3403, 16'sd5992, -16'sd11486, 16'sd6092, -16'sd2534, 16'sd12547, 
    -16'sd6247, 16'sd7786, 16'sd9758, -16'sd1013, 16'sd3298, -16'sd12116, 16'sd8479, -16'sd2600, 16'sd2317, 16'sd8358, 
    -16'sd712, 16'sd2693, 16'sd10619, -16'sd8837, 16'sd3669, -16'sd9013, -16'sd7396, -16'sd5383, -16'sd7719, -16'sd1711, 
    -16'sd5739, 16'sd2293
};

parameter signed [15:0] feature_user7 [0:191] = {
    16'sd6423, -16'sd8167, -16'sd37, 16'sd8195, 16'sd10477, -16'sd5701, 16'sd11447, -16'sd7949, -16'sd4440, -16'sd6975, 
    16'sd13656, 16'sd13336, -16'sd6068, -16'sd3152, 16'sd6462, 16'sd5322, 16'sd8414, 16'sd10652, -16'sd19094, 16'sd5596, 
    16'sd12591, -16'sd2685, 16'sd11664, 16'sd12520, 16'sd8716, -16'sd9144, 16'sd3080, 16'sd2865, -16'sd13780, 16'sd13199, 
    16'sd13034, -16'sd7508, -16'sd6821, -16'sd11118, -16'sd2665, -16'sd2522, -16'sd3933, 16'sd3532, -16'sd13776, -16'sd3424, 
    -16'sd8198, -16'sd6585, 16'sd1622, 16'sd645, 16'sd5871, -16'sd1855, 16'sd6320, 16'sd12652, 16'sd8327, -16'sd11229, 
    -16'sd4547, -16'sd1933, -16'sd4249, 16'sd19834, 16'sd2559, -16'sd16933, -16'sd1317, -16'sd676, -16'sd1187, -16'sd13585, 
    16'sd4134, 16'sd5861, 16'sd367, 16'sd1453, 16'sd3793, 16'sd1073, 16'sd3029, 16'sd5391, -16'sd14034, -16'sd2659, 
    16'sd8809, 16'sd5660, -16'sd5271, -16'sd11996, 16'sd9347, -16'sd571, -16'sd1442, -16'sd16881, 16'sd7396, -16'sd1868, 
    16'sd11514, 16'sd2313, -16'sd12337, -16'sd5620, -16'sd10642, -16'sd1511, -16'sd8928, -16'sd11204, 16'sd9172, 16'sd12740, 
    16'sd6012, -16'sd1241, 16'sd8166, -16'sd8211, 16'sd649, -16'sd4970, 16'sd12726, -16'sd17754, -16'sd5173, -16'sd3809, 
    -16'sd8669, 16'sd9255, 16'sd6207, 16'sd6322, -16'sd7213, -16'sd5905, -16'sd3411, -16'sd4525, 16'sd9613, -16'sd2384, 
    16'sd3110, 16'sd16157, -16'sd6858, 16'sd2190, 16'sd9850, 16'sd104, -16'sd3180, -16'sd12219, -16'sd4685, 16'sd8084, 
    16'sd8452, -16'sd3249, -16'sd19590, -16'sd6091, -16'sd717, 16'sd3548, 16'sd9241, 16'sd4543, 16'sd5884, 16'sd7981, 
    -16'sd10717, 16'sd18725, -16'sd4502, -16'sd12345, -16'sd4247, -16'sd3841, -16'sd6519, -16'sd17679, 16'sd3358, 16'sd8261, 
    -16'sd7016, 16'sd4769, -16'sd7773, -16'sd11978, 16'sd2432, -16'sd17484, -16'sd13691, 16'sd369, 16'sd3108, 16'sd5560, 
    16'sd12170, -16'sd365, 16'sd7291, 16'sd7035, -16'sd6369, -16'sd8264, 16'sd11556, -16'sd11774, 16'sd199, -16'sd2739, 
    -16'sd1129, -16'sd275, -16'sd13047, 16'sd4376, -16'sd7413, 16'sd10332, -16'sd9049, 16'sd71, -16'sd424, 16'sd10583, 
    16'sd3415, 16'sd11275, 16'sd12838, 16'sd10435, -16'sd595, -16'sd10485, 16'sd5494, -16'sd5497, 16'sd7143, 16'sd2130, 
    -16'sd3233, -16'sd7587, 16'sd5192, -16'sd6370, -16'sd14010, -16'sd3512, -16'sd6078, 16'sd1203, -16'sd12841, 16'sd2442, 
    -16'sd1140, -16'sd540
};

parameter signed [15:0] feature_user8 [0:191] = {
    16'sd3705, 16'sd5561, -16'sd9909, 16'sd7236, -16'sd1424, -16'sd10867, 16'sd5231, 16'sd12823, -16'sd7638, 16'sd2571, 
    16'sd1584, 16'sd10797, -16'sd174, -16'sd3953, -16'sd322, 16'sd5437, 16'sd12431, -16'sd1664, -16'sd2759, -16'sd1953, 
    16'sd9544, 16'sd11077, 16'sd7061, 16'sd4689, 16'sd5312, 16'sd7091, 16'sd6685, 16'sd12545, -16'sd6573, 16'sd11847, 
    16'sd11131, -16'sd6201, -16'sd10406, -16'sd1152, 16'sd1346, -16'sd2720, -16'sd1643, 16'sd2457, -16'sd1342, 16'sd2966, 
    -16'sd12026, -16'sd6171, -16'sd6109, 16'sd2349, 16'sd5561, 16'sd802, 16'sd2114, 16'sd5805, 16'sd8369, -16'sd7475, 
    -16'sd1026, -16'sd2540, -16'sd2112, 16'sd2540, 16'sd1011, -16'sd13615, 16'sd4216, -16'sd9190, -16'sd7243, -16'sd6361, 
    -16'sd8279, 16'sd4444, -16'sd534, 16'sd39, 16'sd6971, -16'sd2140, 16'sd3130, -16'sd2553, -16'sd12893, -16'sd314, 
    16'sd11700, -16'sd1992, -16'sd5442, -16'sd4242, 16'sd14168, -16'sd2737, -16'sd1474, 16'sd1567, -16'sd6594, -16'sd1197, 
    16'sd9799, -16'sd4209, -16'sd2542, 16'sd3169, -16'sd10029, 16'sd5437, -16'sd317, -16'sd11634, 16'sd8284, 16'sd11013, 
    -16'sd2659, 16'sd8244, 16'sd5870, 16'sd5809, 16'sd2571, 16'sd6374, 16'sd4594, -16'sd7045, -16'sd5654, -16'sd4381, 
    16'sd4769, 16'sd16630, 16'sd11575, 16'sd12025, 16'sd3235, -16'sd955, 16'sd16200, -16'sd334, -16'sd2759, 16'sd1172, 
    -16'sd1620, 16'sd8149, -16'sd5127, 16'sd4510, 16'sd4911, 16'sd1677, -16'sd3628, 16'sd3932, 16'sd296, 16'sd9409, 
    16'sd359, -16'sd12356, -16'sd23499, -16'sd2070, -16'sd2802, 16'sd3683, 16'sd9460, 16'sd6819, -16'sd360, 16'sd9331, 
    16'sd319, 16'sd13700, 16'sd5432, -16'sd21022, -16'sd379, -16'sd5666, -16'sd88, -16'sd3619, -16'sd3179, 16'sd3329, 
    -16'sd4562, 16'sd8053, -16'sd6514, -16'sd15901, 16'sd1309, -16'sd6853, -16'sd12061, -16'sd729, -16'sd6681, 16'sd8450, 
    16'sd9083, -16'sd10597, 16'sd5350, -16'sd7397, -16'sd1583, -16'sd2509, 16'sd4873, -16'sd665, -16'sd1828, -16'sd3985, 
    16'sd3174, 16'sd2229, -16'sd12137, 16'sd1540, -16'sd9793, 16'sd4267, -16'sd6296, 16'sd3224, -16'sd645, 16'sd8806, 
    -16'sd3174, 16'sd4849, 16'sd6061, -16'sd1695, 16'sd1156, -16'sd2971, 16'sd2118, -16'sd8092, -16'sd4288, 16'sd12694, 
    -16'sd8727, -16'sd3975, 16'sd2962, -16'sd894, 16'sd585, -16'sd1419, -16'sd10662, -16'sd2384, -16'sd14412, -16'sd3515, 
    -16'sd8252, -16'sd7629
};

parameter signed [15:0] feature_user9 [0:191] = {
    16'sd3315, 16'sd859, 16'sd272, 16'sd178, 16'sd8053, -16'sd952, -16'sd461, 16'sd4947, -16'sd11471, 16'sd1134, 
    16'sd1954, 16'sd10806, -16'sd9265, -16'sd2746, 16'sd6571, 16'sd4379, 16'sd3295, 16'sd6970, -16'sd8074, 16'sd7132, 
    16'sd13100, -16'sd2132, 16'sd6881, 16'sd6609, 16'sd3194, -16'sd2391, -16'sd1552, 16'sd5387, -16'sd12232, 16'sd8904, 
    16'sd13890, -16'sd9937, -16'sd4057, -16'sd3593, 16'sd1444, -16'sd2192, 16'sd12, 16'sd3445, -16'sd6554, -16'sd5442, 
    -16'sd4222, -16'sd4022, -16'sd918, 16'sd2966, 16'sd321, -16'sd3206, 16'sd1045, 16'sd12111, -16'sd2232, -16'sd4231, 
    -16'sd807, 16'sd4447, 16'sd3697, 16'sd15259, -16'sd25, -16'sd8893, 16'sd2352, -16'sd6037, 16'sd3151, -16'sd4136, 
    -16'sd544, 16'sd10567, -16'sd2538, 16'sd547, 16'sd10565, 16'sd2260, 16'sd10375, 16'sd2686, -16'sd16603, 16'sd3270, 
    -16'sd1782, -16'sd137, 16'sd3410, -16'sd5056, 16'sd6501, -16'sd7931, -16'sd3819, -16'sd8149, 16'sd3974, -16'sd415, 
    16'sd8324, 16'sd2015, 16'sd303, -16'sd7114, -16'sd11685, -16'sd51, 16'sd1420, -16'sd9091, 16'sd6715, 16'sd7689, 
    16'sd2586, -16'sd81, 16'sd7071, -16'sd1340, -16'sd204, 16'sd1047, 16'sd6014, -16'sd11501, -16'sd8969, -16'sd3088, 
    16'sd672, 16'sd8612, 16'sd1704, 16'sd14880, -16'sd2190, -16'sd2061, 16'sd1665, -16'sd5802, 16'sd4584, -16'sd2905, 
    16'sd339, 16'sd7314, -16'sd4169, -16'sd1565, 16'sd5084, -16'sd1634, -16'sd6244, -16'sd7277, -16'sd2501, -16'sd335, 
    16'sd8981, -16'sd3024, -16'sd16063, -16'sd4820, 16'sd2484, 16'sd500, 16'sd9195, 16'sd5173, 16'sd1641, 16'sd8833, 
    -16'sd7194, 16'sd8767, 16'sd2319, -16'sd8071, 16'sd1440, -16'sd1660, -16'sd224, -16'sd8717, -16'sd6698, 16'sd7004, 
    -16'sd2995, -16'sd1344, 16'sd370, -16'sd13633, 16'sd3913, -16'sd14189, -16'sd6252, 16'sd6906, -16'sd2121, -16'sd3957, 
    16'sd10722, -16'sd4441, -16'sd2941, 16'sd5856, -16'sd7801, -16'sd8183, 16'sd7664, -16'sd3661, 16'sd972, 16'sd2999, 
    16'sd3934, 16'sd1385, -16'sd11157, 16'sd3940, -16'sd3363, 16'sd4574, -16'sd9740, 16'sd2826, -16'sd3638, 16'sd12674, 
    -16'sd5818, 16'sd7120, 16'sd11823, 16'sd1889, -16'sd652, -16'sd14631, 16'sd8069, -16'sd1723, 16'sd3568, 16'sd11948, 
    16'sd453, -16'sd1145, 16'sd12613, -16'sd7990, 16'sd65, -16'sd5549, -16'sd6267, -16'sd4119, -16'sd4634, -16'sd1311, 
    -16'sd6523, -16'sd2011
};

parameter signed [15:0] feature_user10 [0:191] = {
    16'sd3126, -16'sd2477, 16'sd2132, 16'sd5029, 16'sd6372, -16'sd4268, 16'sd356, 16'sd3811, -16'sd5093, 16'sd1214, 
    16'sd3540, 16'sd13963, -16'sd5638, 16'sd2016, -16'sd3479, -16'sd542, 16'sd8709, 16'sd2595, -16'sd4386, 16'sd9659, 
    16'sd13386, 16'sd1236, 16'sd6775, 16'sd11590, -16'sd174, 16'sd606, 16'sd368, 16'sd5494, -16'sd5337, 16'sd11227, 
    16'sd9662, -16'sd6845, -16'sd3820, -16'sd2285, -16'sd1186, -16'sd663, 16'sd1125, 16'sd5857, -16'sd3625, -16'sd3094, 
    -16'sd1157, -16'sd1512, -16'sd1887, -16'sd1511, 16'sd2334, 16'sd2856, 16'sd1024, 16'sd6207, -16'sd403, -16'sd2242, 
    -16'sd935, 16'sd2031, 16'sd964, 16'sd7820, 16'sd1824, -16'sd12062, -16'sd2239, -16'sd6696, 16'sd2916, -16'sd5656, 
    -16'sd2761, 16'sd3034, -16'sd3410, 16'sd864, 16'sd7684, 16'sd2320, 16'sd4260, 16'sd1852, -16'sd15629, -16'sd58, 
    16'sd2379, 16'sd4616, 16'sd2768, 16'sd1193, 16'sd9068, -16'sd1823, -16'sd5134, -16'sd2869, -16'sd1162, 16'sd112, 
    16'sd1700, 16'sd2783, 16'sd1301, -16'sd1422, -16'sd4949, 16'sd4478, -16'sd2112, -16'sd6488, 16'sd5430, 16'sd10802, 
    16'sd1383, -16'sd4256, 16'sd8749, 16'sd152, 16'sd3452, 16'sd4019, 16'sd7233, -16'sd9778, -16'sd4519, -16'sd6910, 
    -16'sd386, 16'sd13344, 16'sd2773, 16'sd7153, 16'sd2564, -16'sd4006, 16'sd6239, -16'sd3111, -16'sd145, -16'sd276, 
    16'sd2833, 16'sd6635, -16'sd603, -16'sd934, 16'sd5947, 16'sd675, -16'sd6427, -16'sd5398, -16'sd1589, 16'sd4020, 
    16'sd7679, -16'sd5797, -16'sd21372, -16'sd1263, -16'sd1142, 16'sd1121, 16'sd2913, -16'sd655, 16'sd1344, 16'sd3531, 
    -16'sd11570, 16'sd10146, 16'sd461, -16'sd7116, -16'sd1612, -16'sd2065, -16'sd900, -16'sd12113, -16'sd2159, 16'sd7452, 
    -16'sd6030, -16'sd529, 16'sd1584, -16'sd8044, -16'sd4535, -16'sd11514, -16'sd5941, -16'sd999, -16'sd3180, -16'sd3429, 
    16'sd12369, -16'sd8839, 16'sd2470, -16'sd640, -16'sd3750, -16'sd3264, 16'sd5041, 16'sd355, 16'sd2554, 16'sd52, 
    -16'sd3619, -16'sd5130, -16'sd10270, 16'sd2219, -16'sd6600, 16'sd2422, -16'sd3742, -16'sd957, 16'sd22, 16'sd156, 
    -16'sd4065, 16'sd6068, 16'sd8550, 16'sd4554, -16'sd474, -16'sd4658, 16'sd9597, -16'sd2880, 16'sd6095, 16'sd6625, 
    -16'sd2511, -16'sd190, 16'sd13040, -16'sd7231, -16'sd8157, -16'sd3833, -16'sd1823, -16'sd3997, 16'sd2024, -16'sd1228, 
    -16'sd6176, -16'sd2933
};


/***********************wire*********************************/
wire sumofsquare_origin_v;
wire [19:0] sumofsquare_origin_out;
 
wire sumofsquare_norm1_v;
wire [19:0] sumofsquare_norm1_out;

wire sumofsquare_norm2_v;
wire [19:0] sumofsquare_norm2_out;


wire sumofsquare_norm3_v;
wire [19:0] sumofsquare_norm3_out;

wire sumofsquare_norm4_v;
wire [19:0] sumofsquare_norm4_out;

wire sumofsquare_norm5_v;
wire [19:0] sumofsquare_norm5_out;

wire sumofsquare_norm6_v;
wire [19:0] sumofsquare_norm6_out;

wire sumofsquare_norm7_v;
wire [19:0] sumofsquare_norm7_out;

wire sumofsquare_norm8_v;
wire [19:0] sumofsquare_norm8_out;

wire sumofsquare_norm9_v;
wire [19:0] sumofsquare_norm9_out;

wire sumofsquare_norm10_v;
wire [19:0] sumofsquare_norm10_out;

wire simularity_v1;    
wire simularity_v2;    
wire simularity_v3;    
wire simularity_v4;    
wire simularity_v5;    
wire simularity_v6;    
wire simularity_v7;    
wire simularity_v8;    
wire simularity_v9;    
wire simularity_v10;    
   
wire [11:0] simularity_out1;
wire [11:0] simularity_out2;
wire [11:0] simularity_out3;
wire [11:0] simularity_out4;
wire [11:0] simularity_out5;
wire [11:0] simularity_out6;
wire [11:0] simularity_out7;
wire [11:0] simularity_out8;
wire [11:0] simularity_out9;
wire [11:0] simularity_out10;


wire signed [11:0] simularity_out11;
wire signed [11:0] simularity_out22;
wire signed [11:0] simularity_out33;
wire signed [11:0] simularity_out44;
wire signed [11:0] simularity_out55;
wire signed [11:0] simularity_out66;
wire signed [11:0] simularity_out77;
wire signed [11:0] simularity_out88;
wire signed [11:0] simularity_out99;
wire signed [11:0] simularity_out1010;


wire  [39:0]  sumofsquare1_unsigned;
wire  [39:0]  sumofsquare2_unsigned;
wire  [39:0]  sumofsquare3_unsigned;
wire  [39:0]  sumofsquare4_unsigned;
wire  [39:0]  sumofsquare5_unsigned;
wire  [39:0]  sumofsquare6_unsigned;
wire  [39:0]  sumofsquare7_unsigned;
wire  [39:0]  sumofsquare8_unsigned;
wire  [39:0]  sumofsquare9_unsigned;
wire  [39:0]  sumofsquare10_unsigned;

/***********************reg*********************************/
reg signed [40:0]  sumofsquare1 [0:191];
reg signed [40:0]  sumofsquare2 [0:191];
reg signed [40:0]  sumofsquare3 [0:191];
reg signed [40:0]  sumofsquare4 [0:191];
reg signed [40:0]  sumofsquare5 [0:191];
reg signed [40:0]  sumofsquare6 [0:191];
reg signed [40:0]  sumofsquare7 [0:191];
reg signed [40:0]  sumofsquare8 [0:191];
reg signed [40:0]  sumofsquare9 [0:191];
reg signed [40:0]  sumofsquare10 [0:191];

reg signed [40:0] sumofsquare_origin[0:191];
reg signed [40:0] sumofsquare_norm1 [0:191];
reg signed [40:0] sumofsquare_norm2 [0:191];
reg signed [40:0] sumofsquare_norm3 [0:191];
reg signed [40:0] sumofsquare_norm4 [0:191];
reg signed [40:0] sumofsquare_norm5 [0:191];
reg signed [40:0] sumofsquare_norm6 [0:191];
reg signed [40:0] sumofsquare_norm7 [0:191];
reg signed [40:0] sumofsquare_norm8 [0:191];
reg signed [40:0] sumofsquare_norm9 [0:191];
reg signed [40:0] sumofsquare_norm10 [0:191];

reg   [7:0] cnt_en;
reg         sqrt_v;


reg [37:0] sqrt_end1;
reg [37:0] sqrt_end2;
reg [37:0] sqrt_end3;
reg [37:0] sqrt_end4;
reg [37:0] sqrt_end5;
reg [37:0] sqrt_end6;
reg [37:0] sqrt_end7;
reg [37:0] sqrt_end8;
reg [37:0] sqrt_end9;
reg [37:0] sqrt_end10;

reg   sumofsquare_norm1_v_reg0;
reg   sumofsquare_norm2_v_reg0;
reg   sumofsquare_norm3_v_reg0;
reg   sumofsquare_norm4_v_reg0;
reg   sumofsquare_norm5_v_reg0;
reg   sumofsquare_norm6_v_reg0;
reg   sumofsquare_norm7_v_reg0;
reg   sumofsquare_norm8_v_reg0;
reg   sumofsquare_norm9_v_reg0;
reg   sumofsquare_norm10_v_reg0;


reg [2:0] compare_result_reg1;
reg [2:0] compare_result_reg2;


/***********************assign******************************/
assign simularity_out11 = sumofsquare1[191][40]? ~simularity_out1+1'b1 : simularity_out1;
assign simularity_out22 = sumofsquare2[191][40]? ~simularity_out2+1'b1 : simularity_out2;
assign simularity_out33 = sumofsquare3[191][40]? ~simularity_out3+1'b1 : simularity_out3;
assign simularity_out44 = sumofsquare4[191][40]? ~simularity_out4+1'b1 : simularity_out4;
assign simularity_out55 = sumofsquare5[191][40]? ~simularity_out5+1'b1 : simularity_out5;
assign simularity_out66 = sumofsquare6[191][40]? ~simularity_out6+1'b1 : simularity_out6;
assign simularity_out77 = sumofsquare7[191][40]? ~simularity_out7+1'b1 : simularity_out7;
assign simularity_out88 = sumofsquare8[191][40]? ~simularity_out8+1'b1 : simularity_out8;
assign simularity_out99 = sumofsquare9[191][40]? ~simularity_out9+1'b1 : simularity_out9;
assign simularity_out1010 = sumofsquare10[191][40]? ~simularity_out10+1'b1 : simularity_out10;

assign sumofsquare1_unsigned = (sumofsquare1[191][40])?~sumofsquare1[191][39:0]:sumofsquare1[191][39:0];
assign sumofsquare2_unsigned = (sumofsquare2[191][40])?~sumofsquare2[191][39:0]:sumofsquare2[191][39:0];
assign sumofsquare3_unsigned = (sumofsquare3[191][40])?~sumofsquare3[191][39:0]:sumofsquare3[191][39:0];
assign sumofsquare4_unsigned = (sumofsquare4[191][40])?~sumofsquare4[191][39:0]:sumofsquare4[191][39:0];
assign sumofsquare5_unsigned = (sumofsquare5[191][40])?~sumofsquare5[191][39:0]:sumofsquare5[191][39:0];
assign sumofsquare6_unsigned = (sumofsquare6[191][40])?~sumofsquare6[191][39:0]:sumofsquare6[191][39:0];
assign sumofsquare7_unsigned = (sumofsquare7[191][40])?~sumofsquare7[191][39:0]:sumofsquare7[191][39:0];
assign sumofsquare8_unsigned = (sumofsquare8[191][40])?~sumofsquare8[191][39:0]:sumofsquare8[191][39:0];
assign sumofsquare9_unsigned = (sumofsquare9[191][40])?~sumofsquare9[191][39:0]:sumofsquare9[191][39:0];
assign sumofsquare10_unsigned = (sumofsquare10[191][40])?~sumofsquare10[191][39:0]:sumofsquare10[191][39:0];


/***********************always******************************/
genvar i;
generate for(i=0;i<192;i=i+1)begin
    always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if(~sys_rst_n)begin
            sumofsquare1[i] <= 'd0;
            sumofsquare2[i] <= 'd0;
            sumofsquare3[i] <= 'd0;
            sumofsquare4[i] <= 'd0;
            sumofsquare5[i] <= 'd0;
            sumofsquare6[i] <= 'd0;
            sumofsquare7[i] <= 'd0;
            sumofsquare8[i] <= 'd0;
            sumofsquare9[i] <= 'd0;
            sumofsquare10[i] <= 'd0;
        end else if(feature_in_en) begin
                if(i == 0) begin
                    sumofsquare1[i] <= feature_in * feature_user1[i];
                    sumofsquare2[i] <= feature_in * feature_user2[i];
                    sumofsquare3[i] <= feature_in * feature_user3[i];
                    sumofsquare4[i] <= feature_in * feature_user4[i];
                    sumofsquare5[i] <= feature_in * feature_user5[i];
                    sumofsquare6[i] <= feature_in * feature_user6[i];
                    sumofsquare7[i] <= feature_in * feature_user7[i];
                    sumofsquare8[i] <= feature_in * feature_user8[i];
                    sumofsquare9[i] <= feature_in * feature_user9[i];
                    sumofsquare10[i] <= feature_in * feature_user10[i];
                end else begin
                    sumofsquare1[i] <= sumofsquare1[i-1] +  feature_in * feature_user1[i];
                    sumofsquare2[i] <= sumofsquare2[i-1] +  feature_in * feature_user2[i];
                    sumofsquare3[i] <= sumofsquare3[i-1] +  feature_in * feature_user3[i];
                    sumofsquare4[i] <= sumofsquare4[i-1] +  feature_in * feature_user4[i];
                    sumofsquare5[i] <= sumofsquare5[i-1] +  feature_in * feature_user5[i];
                    sumofsquare6[i] <= sumofsquare6[i-1] +  feature_in * feature_user6[i];
                    sumofsquare7[i] <= sumofsquare7[i-1] +  feature_in * feature_user7[i];
                    sumofsquare8[i] <= sumofsquare8[i-1] +  feature_in * feature_user8[i];
                    sumofsquare9[i] <= sumofsquare9[i-1] +  feature_in * feature_user9[i];
                    sumofsquare10[i] <= sumofsquare10[i-1] +  feature_in * feature_user10[i];
                end
        end
    end
    
    always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if(~sys_rst_n)begin
            sumofsquare_origin[i] <= 'd0;
             sumofsquare_norm1[i]<= 'd0;
             sumofsquare_norm2[i]<= 'd0;
             sumofsquare_norm3[i]<= 'd0;
             sumofsquare_norm4[i]<= 'd0;
             sumofsquare_norm5[i]<= 'd0;
             sumofsquare_norm6[i]<= 'd0;
             sumofsquare_norm7[i]<= 'd0;
             sumofsquare_norm8[i]<= 'd0;
             sumofsquare_norm9[i]<= 'd0;
             sumofsquare_norm10[i]<= 'd0;
        end else if(feature_in_en)begin
            if(i==0) begin
                sumofsquare_origin[i]  <= feature_in*feature_in;
                sumofsquare_norm1[i]   <= feature_user1[i] * feature_user1[i];
                sumofsquare_norm2[i]   <= feature_user2[i] * feature_user2[i];
                sumofsquare_norm3[i]   <= feature_user3[i] * feature_user3[i];
                sumofsquare_norm4[i]   <= feature_user4[i] * feature_user4[i];
                sumofsquare_norm5[i]   <= feature_user5[i] * feature_user5[i];
                sumofsquare_norm6[i]   <= feature_user6[i] * feature_user6[i];
                sumofsquare_norm7[i]   <= feature_user7[i] * feature_user7[i];
                sumofsquare_norm8[i]   <= feature_user8[i] * feature_user8[i];
                sumofsquare_norm9[i]   <= feature_user9[i] * feature_user9[i];
                sumofsquare_norm10[i]   <= feature_user10[i] * feature_user10[i];
            end else begin
                sumofsquare_origin[i]  <= sumofsquare_origin[i-1] + feature_in*feature_in;
                sumofsquare_norm1[i]   <= sumofsquare_norm1[i-1] + feature_user1[i] * feature_user1[i];
                sumofsquare_norm2[i]   <= sumofsquare_norm2[i-1] + feature_user2[i] * feature_user2[i];
                sumofsquare_norm3[i]   <= sumofsquare_norm3[i-1] + feature_user3[i] * feature_user3[i];
                sumofsquare_norm4[i]   <= sumofsquare_norm4[i-1] + feature_user4[i] * feature_user4[i];
                sumofsquare_norm5[i]   <= sumofsquare_norm5[i-1] + feature_user5[i] * feature_user5[i];
                sumofsquare_norm6[i]   <= sumofsquare_norm6[i-1] + feature_user6[i] * feature_user6[i];
                sumofsquare_norm7[i]   <= sumofsquare_norm7[i-1] + feature_user7[i] * feature_user7[i];
                sumofsquare_norm8[i]   <= sumofsquare_norm8[i-1] + feature_user8[i] * feature_user8[i];
                sumofsquare_norm9[i]   <= sumofsquare_norm9[i-1] + feature_user9[i] * feature_user9[i];
                sumofsquare_norm10[i]   <= sumofsquare_norm10[i-1] + feature_user10[i] * feature_user10[i];
            end
        end

    end 
end
endgenerate


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        cnt_en <= 'd0;
        sqrt_v <= 'd0;
    end else if (cnt_en == Dlength-1'b1)begin
        cnt_en <= cnt_en;
        sqrt_v <= 'd1;
    end else if(feature_in_en) begin
        cnt_en <= cnt_en + 1'b1;
    end else begin
        cnt_en <= cnt_en;
    end
end






always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end1 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm1_v)begin
        sqrt_end1 <= sumofsquare_origin_out * sumofsquare_norm1_out;
    end else begin
        sqrt_end1 <= sqrt_end1;
    end
end




always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end2 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm2_v)begin
        sqrt_end2 <= sumofsquare_origin_out * sumofsquare_norm2_out;
    end else begin
        sqrt_end2 <= sqrt_end2;
    end
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end3 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm3_v)begin
        sqrt_end3 <= sumofsquare_origin_out * sumofsquare_norm3_out;
    end else begin
        sqrt_end3 <= sqrt_end3;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end4 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm4_v)begin
        sqrt_end4 <= sumofsquare_origin_out * sumofsquare_norm4_out;
    end else begin
        sqrt_end4 <= sqrt_end4;
    end
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end5 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm5_v)begin
        sqrt_end5 <= sumofsquare_origin_out * sumofsquare_norm5_out;
    end else begin
        sqrt_end5 <= sqrt_end5;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end6 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm6_v)begin
        sqrt_end6 <= sumofsquare_origin_out * sumofsquare_norm6_out;
    end else begin
        sqrt_end6 <= sqrt_end6;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end7 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm7_v)begin
        sqrt_end7 <= sumofsquare_origin_out * sumofsquare_norm7_out;
    end else begin
        sqrt_end7 <= sqrt_end7;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end8 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm8_v)begin
        sqrt_end8 <= sumofsquare_origin_out * sumofsquare_norm8_out;
    end else begin
        sqrt_end8 <= sqrt_end8;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end9 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm9_v)begin
        sqrt_end9 <= sumofsquare_origin_out * sumofsquare_norm9_out;
    end else begin
        sqrt_end9 <= sqrt_end9;
    end
end

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sqrt_end10 <= 'd0;
    end else if(sumofsquare_origin_v && sumofsquare_norm10_v)begin
        sqrt_end10 <= sumofsquare_origin_out * sumofsquare_norm10_out;
    end else begin
        sqrt_end10 <= sqrt_end10;
    end
end






always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        sumofsquare_norm1_v_reg0 <= 'd0;
        sumofsquare_norm2_v_reg0 <= 'd0;
        sumofsquare_norm3_v_reg0 <= 'd0;
        sumofsquare_norm4_v_reg0 <= 'd0;
        sumofsquare_norm5_v_reg0 <= 'd0;
        sumofsquare_norm6_v_reg0 <= 'd0;
        sumofsquare_norm7_v_reg0 <= 'd0;
        sumofsquare_norm8_v_reg0 <= 'd0;
        sumofsquare_norm9_v_reg0 <= 'd0;
        sumofsquare_norm10_v_reg0 <= 'd0;
    end else begin
        sumofsquare_norm1_v_reg0 <= sumofsquare_norm1_v;
        sumofsquare_norm2_v_reg0 <= sumofsquare_norm2_v;
        sumofsquare_norm3_v_reg0 <= sumofsquare_norm3_v;
        sumofsquare_norm4_v_reg0 <= sumofsquare_norm4_v;
        sumofsquare_norm5_v_reg0 <= sumofsquare_norm5_v;
        sumofsquare_norm6_v_reg0 <= sumofsquare_norm6_v;
        sumofsquare_norm7_v_reg0 <= sumofsquare_norm7_v;
        sumofsquare_norm8_v_reg0 <= sumofsquare_norm8_v;
        sumofsquare_norm9_v_reg0 <= sumofsquare_norm9_v;
        sumofsquare_norm10_v_reg0 <= sumofsquare_norm10_v;
    end
end

wire data_vld_out0;
wire data_vld_out1;
wire data_vld_out2;
wire data_vld_out3;
wire data_vld_out4;


wire [11:0] data_out0;
wire [11:0] data_out1;
wire [11:0] data_out2;
wire [11:0] data_out3;
wire [11:0] data_out4;


 data_comparator
#(
   .DW('d12)

)
data_comparator_inst0
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (simularity_v1 & simularity_v2  )   ,
   .data_a        (simularity_out11       )   ,
   .data_b        (simularity_out22       )   ,
  
   .data_vld_out  (data_vld_out0 )   ,
   .data_out      (data_out0     )
);


 data_comparator
#(
   .DW('d12)

)
data_comparator_inst1
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (simularity_v3 & simularity_v4  )   ,
   .data_a        (simularity_out33       )   ,
   .data_b        (simularity_out44       )   ,
  
   .data_vld_out  (data_vld_out1 )   ,
   .data_out      (data_out1     )
);

 data_comparator
#(
   .DW('d12)

)
data_comparator_inst2
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (simularity_v5 & simularity_v6  )   ,
   .data_a        (simularity_out55       )   ,
   .data_b        (simularity_out66       )   ,
  
   .data_vld_out  (data_vld_out2 )   ,
   .data_out      (data_out2     )
);


 data_comparator
#(
   .DW('d12)

)
data_comparator_inst3
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (simularity_v7 & simularity_v8  )   ,
   .data_a        (simularity_out77       )   ,
   .data_b        (simularity_out88       )   ,
  
   .data_vld_out  (data_vld_out3 )   ,
   .data_out      (data_out3     )
);

 data_comparator
#(
   .DW('d12)

)
data_comparator_inst4
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (simularity_v9 & simularity_v10  )   ,
   .data_a        (simularity_out99       )   ,
   .data_b        (simularity_out1010       )   ,
  
   .data_vld_out  (data_vld_out4 )   ,
   .data_out      (data_out4     )
);

wire data_vld_out55;
wire data_vld_out66;
wire [11:0] data_out55;
wire [11:0] data_out66;

 data_comparator
#(
   .DW('d12)

)
data_comparator_inst5
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (data_vld_out0 & data_vld_out1  )   ,
   .data_a        (data_out0       )   ,
   .data_b        (data_out1       )   ,
  
   .data_vld_out  (data_vld_out55 )   ,
   .data_out      (data_out55     )
);


 data_comparator
#(
   .DW('d12)

)
data_comparator_inst6
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (data_vld_out2 & data_vld_out3  )   ,
   .data_a        (data_out2       )   ,
   .data_b        (data_out3       )   ,
  
   .data_vld_out  (data_vld_out66 )   ,
   .data_out      (data_out66     )
);
wire data_vld_out777;
wire [11:0] data_out777;

 data_comparator
#(
   .DW('d12)

)
data_comparator_inst7
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (data_vld_out55 & data_vld_out66  )   ,
   .data_a        (data_out55       )   ,
   .data_b        (data_out66       )   ,
  
   .data_vld_out  (data_vld_out777 )   ,
   .data_out      (data_out777     )
);

wire data_vld_out8888;
wire [11:0] data_out8888;

 data_comparator
#(
   .DW('d12)

)
data_comparator_inst8
(
   .sys_clk       (sys_clk      )   ,
   .sys_rst_n     (sys_rst_n    )   ,
  
   .data_vld_in   (data_vld_out777 & data_vld_out4  )   ,
   .data_a        (data_out777       )   ,
   .data_b        (data_out4         )   ,
  
   .data_vld_out  (data_vld_out8888 )   ,
   .data_out      (data_out8888     )
);




always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        compare_result_v1 <= 1'b0;
    end else begin
        compare_result_v1 <= data_vld_out8888;
    end
end


always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(~sys_rst_n)begin
        compare_result <= 'd0;
    end else if(data_out8888 == simularity_out11)begin
        compare_result <= 'd1;
    end else if(data_out8888 == simularity_out22)begin
        compare_result <= 'd2;
    end else if(data_out8888 == simularity_out33)begin
        compare_result <= 'd3;
    end else if(data_out8888 == simularity_out44)begin
        compare_result <= 'd4;
    end else if(data_out8888 == simularity_out55)begin
        compare_result <= 'd5;
    end else if(data_out8888 == simularity_out66)begin
        compare_result <= 'd6;
    end else if(data_out8888 == simularity_out77)begin
        compare_result <= 'd7;
    end else if(data_out8888 == simularity_out88)begin
        compare_result <= 'd8;        
    end else if(data_out8888 == simularity_out99)begin
        compare_result <= 'd9;
    end else if(data_out8888 == simularity_out1010)begin
        compare_result <= 'd10;
    end else begin
        compare_result <= 'd0;
    end
end


 
cordic_newton
#(     
     .d_width(40            )   , // this para just for test
     .q_width(19            )   ,
     .r_width(20            ) 
)
cordic_newton_inst0
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_origin[191][39:0]     )    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (sumofsquare_origin_v   )    ,
        .data_o     (sumofsquare_origin_out )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



cordic_newton
#(     
    .d_width(40      )   , // this para just for test
    .q_width(19      )   ,
    .r_width(20      ) 
)
cordic_newton_inst1
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm1[191][39:0]      )    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (sumofsquare_norm1_v    )    ,
        .data_o     (sumofsquare_norm1_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



cordic_newton
#(     
    .d_width(40     )   , // this para just for test
    .q_width(19     )   ,
    .r_width(20     ) 
)
cordic_newton_inst2
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm2[191][39:0]     )    ,//data_21,data_12,data_22, //输入
     
        .o_vaild    (sumofsquare_norm2_v   )    ,
        .data_o     (sumofsquare_norm2_out )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



cordic_newton
#(     
    .d_width(40      )   , // this para just for test
    .q_width(19      )   ,
    .r_width(20      ) 
)
cordic_newton_inst3
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm3[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm3_v    )    ,
        .data_o     (sumofsquare_norm3_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock


cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst4
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm4[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm4_v    )    ,
        .data_o     (sumofsquare_norm4_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock

cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst5
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm5[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm5_v    )    ,
        .data_o     (sumofsquare_norm5_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock


cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst6
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm6[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm6_v    )    ,
        .data_o     (sumofsquare_norm6_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock


cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst7
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm7[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm7_v    )    ,
        .data_o     (sumofsquare_norm7_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock


cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst8
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm8[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm8_v    )    ,
        .data_o     (sumofsquare_norm8_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock

cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst9
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm9[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm9_v    )    ,
        .data_o     (sumofsquare_norm9_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock


cordic_newton
#(     
     .d_width(40      )   , // this para just for test
     .q_width(19      )   ,
     .r_width(20      ) 
)
cordic_newton_inst10
(
        .clk        (sys_clk                )    ,
        .rst        (~sys_rst_n             )    ,   //active high
        .i_vaild    (sqrt_v                 )    ,
        .data_i     (sumofsquare_norm10[191][39:0]      )    ,//data_21,data_12,data_22, //输入
                     
        .o_vaild    (sumofsquare_norm10_v    )    ,
        .data_o     (sumofsquare_norm10_out  )    , //输出
        .data_r     (                       )            //余数
);     //need 27 clock



//需要一个除法IP
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst0
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm1_v_reg0)  ,   //有效信号
    .dividend ( {sumofsquare1_unsigned,10'b0}   )  ,   //被除数
    .divisor  (   sqrt_end1             )  ,   //除数 	 
    .valid_o  (   simularity_v1         )  ,	  
    .quotient (   simularity_out1       )  ,	//商
    .remaind  (                         )   //余数 
    );
    
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst1
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm2_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare2_unsigned,10'b0}   )  ,   //被除数
    .divisor  (   sqrt_end2             )  ,   //除数 	 
    .valid_o  (   simularity_v2         )  ,	  
    .quotient (    simularity_out2      )  ,	//商
    .remaind  (                         )   //余数 
    );
    
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst2
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm3_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare3_unsigned,10'b0}    )  ,   //被除数
    .divisor  (   sqrt_end3             )  ,   //除数 	 
    .valid_o  (   simularity_v3         )  ,	  
    .quotient (    simularity_out3      )  ,	//商
    .remaind  (                         )   //余数 
    );
    
divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst3
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm4_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare4_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end4             )  ,   //除数 	 
    .valid_o  (   simularity_v4         )  ,	  
    .quotient (    simularity_out4      )  ,	//商
    .remaind  (                         )   //余数 
);

divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst4
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm5_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare5_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end5             )  ,   //除数 	 
    .valid_o  (   simularity_v5         )  ,	  
    .quotient (    simularity_out5      )  ,	//商
    .remaind  (                         )   //余数 
);

divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst5
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm6_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare6_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end6             )  ,   //除数 	 
    .valid_o  (   simularity_v6         )  ,	  
    .quotient (    simularity_out6      )  ,	//商
    .remaind  (                         )   //余数 
);

divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst6
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm7_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare7_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end7             )  ,   //除数 	 
    .valid_o  (   simularity_v7         )  ,	  
    .quotient (    simularity_out7      )  ,	//商
    .remaind  (                         )   //余数 
);

divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst7
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm8_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare8_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end8             )  ,   //除数 	 
    .valid_o  (   simularity_v8         )  ,	  
    .quotient (    simularity_out8      )  ,	//商
    .remaind  (                         )   //余数 
);

divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst8
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm9_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare9_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end9             )  ,   //除数 	 
    .valid_o  (   simularity_v9         )  ,	  
    .quotient (    simularity_out9      )  ,	//商
    .remaind  (                         )   //余数 
);

divide#(
   .I_W(50  ),
   .D_W(38  ),
   .O_W(12  )
)
divide_inst9
(
    .clk      (sys_clk                  )  ,
    .reset    (~sys_rst_n               )  ,		   
	.valid_i  ( sumofsquare_norm10_v_reg0)  ,   //有效信号
    .dividend ({sumofsquare10_unsigned,10'b0}     )  ,   //被除数
    .divisor  (   sqrt_end10             )  ,   //除数 	 
    .valid_o  (   simularity_v10         )  ,	  
    .quotient (    simularity_out10      )  ,	//商
    .remaind  (                         )   //余数 
);





endmodule



















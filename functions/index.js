const { onCall } = require("firebase-functions/v2/https");
const { HttpsError } = require("firebase-functions/v2/https"); // استيراد HttpsError مباشرة
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require('firebase-admin');

admin.initializeApp();

let _db = null;
function getDb() {
  _db ??= admin.firestore();
  return _db;
}

// ==================== CONSTANTS ====================
const FAMILY_MATCHING = {
  'زهري': {
    openness: 0.5,
    extraversion: 0.5,
    neuroticism: 0.6,
    freshness: 0.5,
    sweetness: 0.7,
    warmth: 0.4,
    intensity: 0.4
  },
  'شرقي': {
    openness: 0.7,
    extraversion: 0.8,
    neuroticism: 0.4,
    freshness: 0.1,
    sweetness: 0.8,
    warmth: 0.9,
    intensity: 0.8
  },
  'خشبي': {
    openness: 0.6,
    extraversion: 0.4,
    neuroticism: 0.5,
    freshness: 0.3,
    sweetness: 0.3,
    warmth: 0.8,
    intensity: 0.7
  },
  'منعش': {
    openness: 0.4,
    extraversion: 0.6,
    neuroticism: 0.3,
    freshness: 0.9,
    sweetness: 0.2,
    warmth: 0.1,
    intensity: 0.3
  },
  'سرخسي': {
    openness: 0.65,
    extraversion: 0.55,
    neuroticism: 0.5,
    freshness: 0.6,
    sweetness: 0.4,
    warmth: 0.6,
    intensity: 0.6
  }
};

const FAMILY_SCORE_WEIGHT = 0.45;
const CORE_ALIGNMENT_WEIGHT = 0.30;
const CONTEXT_ALIGNMENT_WEIGHT = 0.25;

const INTENSITY_LEVELS = {
  'خفيف': 0.3,
  'معتدل': 0.6,
  'متوسط': 0.6,
  'قوي': 0.9,
  'Light': 0.3,
  'Moderate': 0.6,
  'Strong': 0.9
};

const SWEETNESS_LEVELS = {
  'غير حلو': 0.2,
  'حلو خفيف': 0.4,
  'حلو': 0.6,
  'حلو جداً': 0.8,
  'حلو جدا': 0.8,
  'Dry': 0.2,
  'Light Sweet': 0.4,
  'Sweet': 0.6,
  'Very Sweet': 0.8
};

const FRESHNESS_LEVELS = {
  'دافئ': 0.2,
  'معتدل': 0.5,
  'متوازن': 0.5,
  'منعش': 0.8,
  'Warm': 0.2,
  'Balanced': 0.5,
  'Fresh': 0.8
};

const WARMTH_LEVELS = {
  'بارد': 0.2,
  'محايد': 0.5,
  'دافئ': 0.8,
  'Cool': 0.2,
  'Neutral': 0.5,
  'Warm': 0.8
};

// تحويل المستوى النصي إلى قيمة رقمية
function clamp01(value) {
  const parsed = Number(value);
  if (Number.isNaN(parsed)) return 0.5;
  if (parsed < 0) return 0;
  if (parsed > 1) return 1;
  return parsed;
}

// ????? ??????? ????? ??? ???? ?????
function levelToNumeric(level, mapping, defaultValue = 0.5) {
  if (typeof level === 'number') {
    return clamp01(level);
  }
  if (!level || typeof level !== 'string') {
    return defaultValue;
  }
  return mapping[level] ?? defaultValue;
}

// تطبيع اسم العائلة
function normalizeFamily(family) {
  if (!family) return 'منعش';
  const familyMap = {
    'زهري': 'زهري',
    'شرقي': 'شرقي',
    'خشبي': 'خشبي',
    'منعش': 'منعش',
    'سرخسي': 'سرخسي',
    'Fougere': 'سرخسي',
    'Fresh': 'منعش',
    'Floral': 'زهري',
    'Oriental': 'شرقي',
    'Woody': 'خشبي'
  };
  return familyMap[family] || 'منعش';
}

// حساب family score
function calculateFamilyScore(profile, weights) {
  const openness = profile.openness ?? 0.5;
  const extraversion = profile.extraversion ?? 0.5;
  const neuroticism = profile.neuroticism ?? 0.5;
  const freshnessPref = profile.freshnessPreference ?? 0.5;
  const sweetnessPref = profile.sweetnessPreference ?? 0.5;
  const warmthPref = profile.warmthPreference ?? 0.5;
  const intensityPref = profile.intensityPreference ?? 0.5;

  let score = 0;
  score += openness * weights.openness;
  score += extraversion * weights.extraversion;
  score += (1 - neuroticism) * (1 - weights.neuroticism);
  score += freshnessPref * weights.freshness;
  score += sweetnessPref * weights.sweetness;
  score += warmthPref * weights.warmth;
  score += intensityPref * weights.intensity;

  return score / 7;
}

// حساب preference alignment
function calculatePreferenceAlignment(profile, perfume) {
  const freshnessPref = profile.freshnessPreference ?? 0.5;
  const sweetnessPref = profile.sweetnessPreference ?? 0.5;
  const warmthPref = profile.warmthPreference ?? 0.5;
  const intensityPref = profile.intensityPreference ?? 0.5;

  const freshnessValue = levelToNumeric(perfume.freshnessLevel, FRESHNESS_LEVELS, 0.5);
  const sweetnessValue = levelToNumeric(perfume.sweetnessLevel, SWEETNESS_LEVELS, 0.5);
  const warmthValue = levelToNumeric(perfume.warmthLevel, WARMTH_LEVELS, 0.5);
  const intensityValue = levelToNumeric(perfume.intensityLevel, INTENSITY_LEVELS, 0.5);

  let alignment = 0;
  alignment += (1 - Math.abs(freshnessPref - freshnessValue)) / 4;
  alignment += (1 - Math.abs(sweetnessPref - sweetnessValue)) / 4;
  alignment += (1 - Math.abs(warmthPref - warmthValue)) / 4;
  alignment += (1 - Math.abs(intensityPref - intensityValue)) / 4;

  return alignment;
}

function closeness(target, value) {
  return clamp01(1 - Math.abs(target - value));
}

function familyLuxuryBaseline(family) {
  const weights = FAMILY_MATCHING[family];
  if (!weights) return 0.5;
  return clamp01(
    (weights.warmth * 0.4) +
      (weights.intensity * 0.35) +
      (weights.sweetness * 0.25),
  );
}

function resolveUsageSignal({ intensityValue, warmthValue, freshnessValue }) {
  return clamp01((intensityValue * 0.45) + (warmthValue * 0.35) + (freshnessValue * 0.20));
}

function resolveProjectionSignal({ perfume, intensityValue }) {
  if (typeof perfume.projection === 'number') {
    return clamp01(perfume.projection);
  }
  return clamp01(intensityValue);
}

function resolveLongevitySignal({ perfume, intensityValue, warmthValue }) {
  if (typeof perfume.longevity === 'number') {
    return clamp01(perfume.longevity);
  }
  return clamp01((intensityValue * 0.6) + (warmthValue * 0.4));
}

function resolveLuxurySignal({ perfume, normalizedFamily }) {
  if (typeof perfume.luxuryScore === 'number') {
    return clamp01(perfume.luxuryScore);
  }
  return familyLuxuryBaseline(normalizedFamily);
}

function resolveImpressionSignal({ sweetnessValue, projectionSignal, luxurySignal }) {
  return clamp01((projectionSignal * 0.4) + (luxurySignal * 0.35) + (sweetnessValue * 0.25));
}

function calculateContextPreferenceAlignment(profile, perfume, normalizedFamily) {
  const usagePref = profile.usagePreference ?? 0.5;
  const projectionPref = profile.projectionPreference ?? 0.5;
  const longevityPref = profile.longevityPreference ?? 0.5;
  const impressionPref = profile.impressionPreference ?? 0.5;
  const luxuryPref = profile.luxuryPreference ?? 0.5;

  const freshnessValue = levelToNumeric(perfume.freshnessLevel, FRESHNESS_LEVELS, 0.5);
  const sweetnessValue = levelToNumeric(perfume.sweetnessLevel, SWEETNESS_LEVELS, 0.5);
  const warmthValue = levelToNumeric(perfume.warmthLevel, WARMTH_LEVELS, 0.5);
  const intensityValue = levelToNumeric(perfume.intensityLevel, INTENSITY_LEVELS, 0.5);

  const usageSignal = resolveUsageSignal({ intensityValue, warmthValue, freshnessValue });
  const projectionSignal = resolveProjectionSignal({ perfume, intensityValue });
  const longevitySignal = resolveLongevitySignal({ perfume, intensityValue, warmthValue });
  const luxurySignal = resolveLuxurySignal({ perfume, normalizedFamily });
  const impressionSignal = resolveImpressionSignal({ sweetnessValue, projectionSignal, luxurySignal });

  let alignment = 0;
  alignment += closeness(usagePref, usageSignal);
  alignment += closeness(projectionPref, projectionSignal);
  alignment += closeness(longevityPref, longevitySignal);
  alignment += closeness(impressionPref, impressionSignal);
  alignment += closeness(luxuryPref, luxurySignal);

  return alignment / 5;
}

function normalizeGender(value) {
  const normalized = String(value || '').trim().toLowerCase();
  if (
    normalized === 'male' ||
    normalized === 'm' ||
    normalized === 'ذكر'
  ) {
    return 'male';
  }
  if (
    normalized === 'female' ||
    normalized === 'f' ||
    normalized === 'أنثى' ||
    normalized === 'انثى' ||
    normalized === 'انثي'
  ) {
    return 'female';
  }
  if (
    normalized === 'unisex' ||
    normalized === 'both' ||
    normalized === 'all' ||
    normalized === 'للجنسين'
  ) {
    return 'unisex';
  }
  return normalized;
}

// التحقق الصارم من توافق الجنس
function genderMatches(perfumeGender, userGender) {
  const normalizedPerfume = normalizeGender(perfumeGender);
  const normalizedUser = normalizeGender(userGender);

  if (!normalizedUser) return normalizedPerfume === 'unisex';
  if (!normalizedPerfume) return false;
  return normalizedPerfume === normalizedUser;
}

// ==================== 2nd Gen FUNCTION with Auth ====================
exports.getRecommendationV2 = onCall(
  {
    region: 'us-central1',
    memory: '256MiB',
    timeoutSeconds: 60,
    minInstances: 0
  },
  async (request) => {
    try {
      // 1) Basic authentication check
      if (!request.auth) {
        throw new HttpsError(
          'unauthenticated',
          'User must be authenticated to call this function'
        );
      }

      const { profile, storeId, gender } = request.data;
      const userId = request.auth.uid;

      // 2) Basic required input validation
      if (!profile || !storeId) {
        throw new HttpsError(
          'invalid-argument',
          'Profile and storeId are required'
        );
      }

      // 3) Verify user exists
      const userDoc = await getDb().collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw new HttpsError(
          'permission-denied',
          'User not found'
        );
      }

      // 4) Optional role-based store access check
      const userData = userDoc.data();
      if (userData?.role === 'store' && userData?.storeId !== storeId) {
        throw new HttpsError(
          'permission-denied',
          'User does not have access to this store'
        );
      }

      // 5) Verify store exists and is active
      const storeDoc = await getDb().collection('stores').doc(storeId).get();
      if (!storeDoc.exists) {
        throw new HttpsError(
          'not-found',
          'Store not found'
        );
      }

      const storeData = storeDoc.data();
      if (!storeData?.active) {
        throw new HttpsError(
          'failed-precondition',
          'Store is not active'
        );
      }

      // 1. تحديد أفضل عائلة عطرية
      let bestFamily = 'منعش';
      let bestScore = -1;

      for (const [family, weights] of Object.entries(FAMILY_MATCHING)) {
        const familyScore = calculateFamilyScore(profile, weights);
        if (familyScore > bestScore) {
          bestScore = familyScore;
          bestFamily = family;
        }
      }

      // 2. جلب العطور من المتجر
      const perfumesRef = getDb()
        .collection('stores')
        .doc(storeId)
        .collection('perfumes')
        .where('active', '==', true);

      const snapshot = await perfumesRef.get();

      if (snapshot.empty) {
        return {
          success: true,
          family: bestFamily,
          mainRecommendation: null,
          alternatives: [],
          all: []
        };
      }

      // 3. حساب scores للعطور
      const recommendations = [];

      for (const doc of snapshot.docs) {
        const perfume = doc.data();
        perfume.id = doc.id;

        const perfumeFamily = normalizeFamily(perfume.family);
        const familyWeights = FAMILY_MATCHING[bestFamily];
        const familyScore = calculateFamilyScore(profile, familyWeights);
        const coreAlignment = calculatePreferenceAlignment(profile, perfume);
        const contextAlignment = calculateContextPreferenceAlignment(
          profile,
          perfume,
          perfumeFamily,
        );

        let totalScore =
          (familyScore * FAMILY_SCORE_WEIGHT) +
          (coreAlignment * CORE_ALIGNMENT_WEIGHT) +
          (contextAlignment * CONTEXT_ALIGNMENT_WEIGHT);

        if (!genderMatches(perfume.genderTarget, gender)) {
          continue;
        }

        if (perfumeFamily === bestFamily) {
          totalScore *= 1.2;
        }

        totalScore = clamp01(totalScore);

        recommendations.push({ ...perfume, matchScore: totalScore });
      }

      recommendations.sort((a, b) => b.matchScore - a.matchScore);

      if (recommendations.length === 0) {
        return {
          success: true,
          family: bestFamily,
          mainRecommendation: null,
          alternatives: [],
          all: [],
          message: 'no_gender_match'
        };
      }

      // 4. توليد سبب مقنع
      let reason = '';
      if (bestFamily === 'منعش') reason = 'نشيط ومنعش، مثالي لشخصيتك المنطلقة';
      else if (bestFamily === 'زهري') reason = 'أنيق وجذاب، يعكس رقتك وحساسيتك';
      else if (bestFamily === 'شرقي') reason = 'دافئ وجريء، يليق بشخصيتك القوية';
      else if (bestFamily === 'خشبي') reason = 'كلاسيكي ومتين، يعبر عن ثقتك بنفسك';
      else if (bestFamily === 'سرخسي') reason = 'منعش وحيوي، يناسب شخصيتك النشطة';

      const mainRecommendation = { ...recommendations[0], reason };
      const alternatives = recommendations.length > 1 ? recommendations.slice(1, 7) : [];
      const all = recommendations.slice(0, 7);

      console.log(`User ${userId} requested recommendation for store ${storeId}`);

      return {
        success: true,
        family: bestFamily,
        mainRecommendation,
        alternatives,
        all
      };

    } catch (error) {
      console.error('Error in getRecommendationV2:', error);

      // إذا كان الخطأ من نوع HttpsError، نعيده كما هو
      if (error instanceof HttpsError) {
        throw error;
      }

      // وإلا نعيد خطأ داخلي
      throw new HttpsError('internal', error.message);
    }
  }
);

// ==================== EEG Stats Aggregation (Scheduled) ====================
exports.updateEEGStats = onSchedule(
  {
    schedule: "0 * * * *",
    timeZone: "Asia/Riyadh",
    memory: "512MiB",
    timeoutSeconds: 540,
  },
  async () => {
    try {
      console.log("Starting EEG stats update...");

      const storesSnapshot = await getDb()
        .collection('stores')
        .where('active', '==', true)
        .get();

      let totalPerfumes = 0;
      let updatedPerfumes = 0;

      for (const storeDoc of storesSnapshot.docs) {
        const storeId = storeDoc.id;

        const perfumesSnapshot = await getDb()
          .collection('stores')
          .doc(storeId)
          .collection('perfumes')
          .where('active', '==', true)
          .get();

        for (const perfumeDoc of perfumesSnapshot.docs) {
          const perfumeId = perfumeDoc.id;
          totalPerfumes++;

          try {
            await _updateSinglePerfumeStats(perfumeId);
            updatedPerfumes++;
          } catch (error) {
            console.error(`Error updating perfume ${perfumeId}:`, error);
          }
        }
      }

      console.log(
        `EEG stats update completed. Total: ${totalPerfumes}, Updated: ${updatedPerfumes}`,
      );
    } catch (error) {
      console.error('Error in updateEEGStats:', error);
    }
  },
);

async function _updateSinglePerfumeStats(perfumeId) {
  const eegSnapshot = await getDb()
    .collection('eeg_results')
    .where('perfumeId', '==', perfumeId)
    .get();

  if (eegSnapshot.empty) {
    await getDb().collection('eeg_stats').doc(perfumeId).delete();
    return;
  }

  let relaxationSum = 0;
  let attentionSum = 0;
  let engagementSum = 0;
  let excitementSum = 0;
  let stressSum = 0;
  let interestSum = 0;
  let count = 0;

  for (const doc of eegSnapshot.docs) {
    const data = doc.data();
    relaxationSum += data.relaxation || 0;
    attentionSum += data.attention || 0;
    engagementSum += data.engagement || 0;
    excitementSum += data.excitement || 0;
    stressSum += data.stress || 0;
    interestSum += data.interest || 0;
    count++;
  }

  const recentIds = [...eegSnapshot.docs]
    .sort((a, b) => {
      const aTime = a.data().createdAt?.toDate?.() || new Date(0);
      const bTime = b.data().createdAt?.toDate?.() || new Date(0);
      return bTime - aTime;
    })
    .slice(0, 10)
    .map((doc) => doc.id);

  const stats = {
    perfumeId,
    count,
    avgRelaxation: relaxationSum / count,
    avgAttention: attentionSum / count,
    avgEngagement: engagementSum / count,
    avgExcitement: excitementSum / count,
    avgStress: stressSum / count,
    avgInterest: interestSum / count,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    recentIds,
  };

  await getDb().collection('eeg_stats').doc(perfumeId).set(stats);
}



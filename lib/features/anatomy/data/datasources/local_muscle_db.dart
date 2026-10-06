import '../../domain/entities/muscle.dart';

class LocalMuscleDb {
  static final Map<String, Muscle> muscles = {
    'chest': const Muscle(
      id: 'chest',
      name: 'Pectorals (Chest)',
      details: 'The pectoralis major makes up the bulk of the chest muscle. It consists of two heads: the clavicular (upper) head and the sternocostal (lower/mid) head.',
      function: 'Horizontal adduction and internal rotation of the humerus. Primary pushing mechanics.',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Flat Dumbbell Press', desc: 'Builds thick muscle fibers with high range of motion. Keep elbows at 45 degrees.'),
        Exercise(type: 'Machine', title: 'Pec Dec Flyes', desc: 'Isolates the chest muscles, maintaining tension throughout the entire squeeze.'),
        Exercise(type: 'Home', title: 'Incline Push-ups', desc: 'Leverage bodyweight to target the lower pectorals using household elevations.')
      ],
      mistakes: [
        Mistake(risk: 'High Injury', title: 'Elbow Flare (90 degrees)', desc: 'Flaring elbows puts extreme stress on the rotator cuffs. Keep elbows tucked to 45-60 degrees.'),
        Mistake(risk: 'Low Output', title: 'Half Reps', desc: 'Shortening the bottom stretch or failing to lock out reduces fiber recruitment by up to 40%.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Doorway Pec Stretch', desc: 'Place forearms on door frame, step forward slowly until stretch is felt in chest. Hold 30s.'),
        Stretch(type: 'Mobility', title: 'Scapular Retractions', desc: 'Improves shoulder blade health to build a safer base for heavy pressing.')
      ],
      nutrition: [
        Nutrition(type: 'Protein', title: 'Whey Isolate', desc: 'Fast-absorbing amino acids directly to pectoral fibers immediately post-hypertrophy.'),
        Nutrition(type: 'Recovery', title: 'Cherry Juice', desc: 'Reduces DOMS (delayed onset muscle soreness) in chest after heavy bench sessions.')
      ]
    ),
    'abs': const Muscle(
      id: 'abs',
      name: 'Rectus Abdominis (Abs)',
      details: 'The rectus abdominis runs vertically along the front of the abdomen. It is crossed by bands of connective tissue, producing the "six-pack" appearance.',
      function: 'Flexion of the lumbar spine (bending forward) and stabilizing the core against forces.',
      exercises: [
        Exercise(type: 'Exercises', title: 'Hanging Leg Raises', desc: 'Targets lower abs. Avoid swinging; use hips and abs to curl the pelvis upwards.'),
        Exercise(type: 'Machine', title: 'Cable Crunches', desc: 'Adds progressive resistance to spinal flexion. Keep hips locked, pull with abs.'),
        Exercise(type: 'Home', title: 'Plank to Hollow Body Hold', desc: 'Builds isometric structural strength and deep core stability.')
      ],
      mistakes: [
        Mistake(risk: 'Back Strain', title: 'Using Hip Flexors', desc: 'Pulling from the hip joints instead of flexing the spine transfers loading away from abs and puts strain on the lower back.'),
        Mistake(risk: 'Neck Strain', title: 'Pulling Behind Neck', desc: 'Interlocking fingers behind the head during crunches forces the neck out of alignment.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Cobra Stretch', desc: 'Lie face down, press palms into ground, extend torso upward to stretch front abdominal wall.'),
        Stretch(type: 'Mobility', title: 'Cat-Cow Flow', desc: 'Increases lumbar spine flexibility and relieves abdominal tension.')
      ],
      nutrition: [
        Nutrition(type: 'Hydration', title: 'Electrolyte Infusions', desc: 'Crucial to prevent painful abdominal cramping during high-volume contraction workouts.'),
        Nutrition(type: 'Metabolism', title: 'Healthy Fats', desc: 'Avocados and olive oil support metabolic health and assist in leaning down to reveal core.')
      ]
    ),
    'quads': const Muscle(
      id: 'quads',
      name: 'Quadriceps (Thighs)',
      details: 'Comprising four distinct muscle heads (Rectus Femoris, Vastus Lateralis, Vastus Medialis, Vastus Intermedius) on the front of the thigh.',
      function: 'Knee extension (straightening the leg) and hip flexion (lifting the leg towards the chest).',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Bulgarian Split Squats', desc: 'Unilateral leg developer. Targets quads heavily while strengthening hip stabilizers.'),
        Exercise(type: 'Machine', title: 'Leg Press / Hack Squat', desc: 'Safely isolate the quadriceps without systemic lower-back fatigue. Keep heels flat.'),
        Exercise(type: 'Home', title: 'Cyclist Squats', desc: 'Squatting with heels elevated on a wedge shifts mechanical load directly onto the lower quad sweep.')
      ],
      mistakes: [
        Mistake(risk: 'Knee Valgus', title: 'Knees Caving Inward', desc: 'When squatting, knees caving inside creates massive shear forces on the ACL. Push knees outward actively.'),
        Mistake(risk: 'Imbalance', title: 'Lifting Heels', desc: 'Lifting heels shifts weight to toes, loading the knee joints instead of the quad fibers.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Couch Stretch', desc: 'Place back knee against a wall, step other foot forward, stand tall. Deeply opens hip flexor & quad.'),
        Stretch(type: 'Mobility', title: 'World\'s Greatest Stretch', desc: 'Opens up hips, ankles, and thoracic spine for deep pain-free squat ranges.')
      ],
      nutrition: [
        Nutrition(type: 'Carbs', title: 'Sweet Potato', desc: 'Replenishes glycogen levels inside the quad vaults after high-volume leg days.'),
        Nutrition(type: 'Supplement', title: 'Creatine Monohydrate', desc: 'Saturates cellular phosphate reserves to power heavy leg presses.')
      ]
    ),
    'biceps': const Muscle(
      id: 'biceps',
      name: 'Biceps Brachii (Arms)',
      details: 'A two-headed muscle (Short Head and Long Head) on the front of the upper arm. It spans two joints: the shoulder and the elbow.',
      function: 'Flexion of the elbow joint and supination of the forearm (turning the palm upwards).',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Incline Inward Dumbbell Curl', desc: 'Stretches the long head of the bicep behind the torso for maximum peak construction.'),
        Exercise(type: 'Machine', title: 'Preacher Curl Machine', desc: 'Eliminates body momentum. Locks elbows in place to isolate biceps at the bottom contraction.'),
        Exercise(type: 'Home', title: 'Chin-ups', desc: 'Underhand grip pull-up variation that heavily loads the biceps with full bodyweight.')
      ],
      mistakes: [
        Mistake(risk: 'Joint Strain', title: 'Elbow Drift', desc: 'Swinging elbows forward shifts tension from biceps to anterior shoulders. Keep elbows locked to side.'),
        Mistake(risk: 'Low Range', title: 'Skipping Lower Stretch', desc: 'Failing to fully extend the elbow prevents structural growth at the long head connection.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Wall Bicep Stretch', desc: 'Place palm flat on wall at shoulder height, rotate body away until tension is felt in arm.'),
        Stretch(type: 'Mobility', title: 'Wrist Rotations', desc: 'Keeps forearm tendons flexible, protecting elbow joints from tendinitis.')
      ],
      nutrition: [
        Nutrition(type: 'Blood Flow', title: 'L-Citrulline / Nitric Oxide', desc: 'Boosts blood flow for maximum nutrient delivery and "muscle pump" during arm training.')
      ]
    ),
    'shoulders': const Muscle(
      id: 'shoulders',
      name: 'Deltoids (Shoulders)',
      details: 'A three-headed muscle covering the shoulder joint. Comprises the Anterior (front), Lateral (side), and Posterior (rear) deltoids.',
      function: 'Abduction, flexion, and horizontal extension of the arm. Dictates shoulder width and visual taper.',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Lateral Raises', desc: 'Builds width by isolating lateral deltoids. Lean forward slightly and raise arms to 45 degrees.'),
        Exercise(type: 'Machine', title: 'Overhead Shoulder Press', desc: 'Excellent overall strength builder. Keep core tight and avoid hyperextending lower back.'),
        Exercise(type: 'Home', title: 'Pike Pushups', desc: 'Elevate hips to form a V-shape, lower head towards ground to load anterior shoulders.')
      ],
      mistakes: [
        Mistake(risk: 'Impingement', title: 'Internal Rotation Raises', desc: 'Pouring out the pitcher (pinky up) during lateral raises pinches tendons. Lead with elbows.'),
        Mistake(risk: 'Rotator Injury', title: 'Flaring on Shoulder Press', desc: 'Pressing with elbows wide flares shoulder sockets. Bring elbows slightly forward in the scapular plane.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Cross-Body Stretch', desc: 'Pull arm across chest with other hand, keeping shoulder blade depressed. Holds 25s.'),
        Stretch(type: 'Mobility', title: 'Band Dislocates', desc: 'Loop band, rotate arms overhead front-to-back. Restores joint mobility.')
      ],
      nutrition: [
        Nutrition(type: 'Joints', title: 'Omega-3 Fatty Acids', desc: 'Essential for keeping sensitive shoulder joint capsules lubricated and inflammation-free.')
      ]
    ),
    'back': const Muscle(
      id: 'back',
      name: 'Lats & Traps (Back)',
      details: 'The Latissimus Dorsi is the broadest muscle of the back, creating the V-taper. The Trapezius spans the upper spine and stabilizes shoulder blades.',
      function: 'Shoulder extension, adduction, and scapular retraction (pulling shoulders back).',
      exercises: [
        Exercise(type: 'Exercises', title: 'Chest-Supported Row', desc: 'Isolates middle back without lower back fatigue. Focus on pulling with elbows.'),
        Exercise(type: 'Machine', title: 'Lat Pulldown', desc: 'Neutral grip targets lat fibers down the side. Pull bar to upper collarbone.'),
        Exercise(type: 'Home', title: 'Pull-ups', desc: 'The ultimate gold-standard test for upper-body pulling strength. Full range.')
      ],
      mistakes: [
        Mistake(risk: 'Spine Injury', title: 'Lumbar Rounding', desc: 'Rounding the spine during rows damages discs under load. Maintain a flat, neutral spine.'),
        Mistake(risk: 'Arm Dominance', title: 'Pulling with Hands', desc: 'Initiating pull with biceps instead of retracting shoulder blades leaves the back under-stimulated.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Lat Hang', desc: 'Hang loosely from a pull-up bar, relaxing shoulders to fully decompress spine and lats.'),
        Stretch(type: 'Mobility', title: 'Thoracic Spine Extensions', desc: 'Roll upper back on a foam roller to keep thoracic spine mobile.')
      ],
      nutrition: [
        Nutrition(type: 'Joint Health', title: 'Collagen & Vitamin C', desc: 'Strengthens dense back tendons and ligament connections.')
      ]
    ),
    'forearms': const Muscle(
      id: 'forearms',
      name: 'Forearms (Grip)',
      details: 'Composed of multiple small muscles controlling wrist flexion, extension, and finger movement.',
      function: 'Grip support, wrist rotation, and forearm stabilization.',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Hammer Curls', desc: 'Hits brachioradialis and forearm extensor muscles simultaneously.'),
        Exercise(type: 'Exercises', title: 'Farmer Carries', desc: 'Builds crushing isometric grip strength. Walk slowly keeping posture tall.')
      ],
      mistakes: [
        Mistake(risk: 'Wrist Strain', title: 'Over-flexing Wrist', desc: 'Curling wrist excessively on biceps exercises stresses wrist joints. Keep wrists neutral.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Prayer Stretch', desc: 'Place palms together at chest level, push down slowly to stretch flexors.')
      ],
      nutrition: [
        Nutrition(type: 'Minerals', title: 'Magnesium', desc: 'Aids muscle relaxation, preventing forearms from clamping up during heavy lifts.')
      ]
    ),
    'calves': const Muscle(
      id: 'calves',
      name: 'Gastrocnemius (Calves)',
      details: 'Located at the back of the lower leg. Consists of the Gastrocnemius and the Soleus. Connected via Achilles tendon.',
      function: 'Plantar flexion (pushing foot downward) and assisting in knee bending.',
      exercises: [
        Exercise(type: 'Exercises', title: 'Single-Leg Calf Raises', desc: 'Isolates side-to-side leg imbalances. Pause 2s at bottom stretch.'),
        Exercise(type: 'Machine', title: 'Seated Calf Raise', desc: 'Bends knee to target the soleus muscle specifically.')
      ],
      mistakes: [
        Mistake(risk: 'No Growth', title: 'Bouncing / Rep Momentum', desc: 'Bouncing leverages Achilles elastic energy instead of working calf fibers. Pause at transition.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Wall Calf Stretch', desc: 'Place toe high against wall, lean hip forward to stretch lower leg.')
      ],
      nutrition: [
        Nutrition(type: 'Hydration', title: 'Sodium/Hydration Balance', desc: 'Calves are highly prone to sudden nocturnal cramping; ensure high mineral and water intake.')
      ]
    ),
    'triceps': const Muscle(
      id: 'triceps',
      name: 'Triceps Brachii (Arms Back)',
      details: 'A three-headed muscle making up 60% of the upper arm volume. Comprises Lateral, Medial, and Long heads.',
      function: 'Extension of elbow joint. Overhead positions target the long head.',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Overhead Extensions', desc: 'Stretches long head deeply. Keep upper arm vertical.'),
        Exercise(type: 'Machine', title: 'Tricep Pushdowns', desc: 'Isolates triceps cleanly. Flare hands slightly outwards at bottom.')
      ],
      mistakes: [
        Mistake(risk: 'Elbow Pain', title: 'Elbows Flaring Out', desc: 'Allows shoulders to assist, applying rotational stress to elbow ligaments. Pin elbows in.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Overhead Tricep Stretch', desc: 'Reach arm down back, pull elbow downward with opposite hand.')
      ],
      nutrition: [
        Nutrition(type: 'Synthesis', title: 'BCAAs/Leucine', desc: 'High concentration of Leucine signals muscle building pathway (mTOR) after tricep overload.')
      ]
    ),
    'glutes': const Muscle(
      id: 'glutes',
      name: 'Gluteus Maximus (Glutes)',
      details: 'The largest and most powerful muscle in the human body, key for locomotion and upright posture.',
      function: 'Hip extension, lateral rotation, and abduction of the hip.',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Glute Bridges', desc: 'Locks knees to focus purely on hip extension. Squeeze hard at peak.'),
        Exercise(type: 'Machine', title: 'Hip Thrusts', desc: 'Excellent loading capacity for glutes. Keep chin tucked and ribs down.')
      ],
      mistakes: [
        Mistake(risk: 'Back Pain', title: 'Lower Back Arching', desc: 'Arching lower back instead of tilting pelvis at the top causes lumbar strain.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Figure-Four Stretch', desc: 'Cross ankle over opposite knee, pull knee towards chest to stretch outer glute.')
      ],
      nutrition: [
        Nutrition(type: 'Repair', title: 'Glutamine', desc: 'Assists gut health and cellular muscle repair after heavy posterior-chain load.')
      ]
    ),
    'hamstrings': const Muscle(
      id: 'hamstrings',
      name: 'Hamstrings (Legs Back)',
      details: 'Group of three muscles at the back of the thigh. Highly prone to strains if quadriceps are disproportionately stronger.',
      function: 'Knee flexion and hip extension.',
      exercises: [
        Exercise(type: 'Dumbbell', title: 'Romanian Deadlifts', desc: 'Outstanding hamstring stretch under load. Push hips backward, keeping back straight.'),
        Exercise(type: 'Machine', title: 'Lying Leg Curls', desc: 'Isolates knee flexion. Keep hips pressed flat into pad to avoid cheating.')
      ],
      mistakes: [
        Mistake(risk: 'Tear Risk', title: 'Hyperextending Knees', desc: 'Locking out joints abruptly during extensions/RDLs causes ligament strain. Maintain micro-bend.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Toe Touch', desc: 'Hinge at hips, reach for toes keeping spine straight until back-thigh stretch is felt.')
      ],
      nutrition: [
        Nutrition(type: 'Mobility', title: 'Turmeric (Curcumin)', desc: 'Natural anti-inflammatory to soothe tight, rigid hamstring fibers.')
      ]
    ),
    'neck': const Muscle(
      id: 'neck',
      name: 'Cervical Spine (Neck)',
      details: 'Multiple small muscles stabilizing head orientation. Often overlooked but critical for collision sports.',
      function: 'Neck rotation, lateral flexion, and extension.',
      exercises: [
        Exercise(type: 'Home', title: 'Isometric Neck Press', desc: 'Press hand against head, resist with neck muscles. Hold 10s. Do front, sides, back.')
      ],
      mistakes: [
        Mistake(risk: 'Vertebrae Compression', title: 'Rapid Head Jerking', desc: 'Never perform fast explosive movements on neck muscles. Only slow isometric loading.')
      ],
      stretches: [
        Stretch(type: 'Stretch', title: 'Side Bend Neck Stretch', desc: 'Gently tilt ear towards shoulder. Hold, breathing deeply. Do not pull hard.')
      ],
      nutrition: [
        Nutrition(type: 'Nerves', title: 'B-Complex Vitamins', desc: 'Supports healthy nerve signaling down the cervical spine path.')
      ]
    )
  };
}

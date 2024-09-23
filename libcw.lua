#!/usr/bin/env luajit
local ffi=require"ffi"

--[[
/* Default outputs for audio systems. Used by libcw unless
   client code decides otherwise. */
#define CW_DEFAULT_NULL_DEVICE      ""
#define CW_DEFAULT_CONSOLE_DEVICE   "/dev/console"
#define CW_DEFAULT_OSS_DEVICE       "/dev/audio"
#define CW_DEFAULT_ALSA_DEVICE      "default"
#define CW_DEFAULT_PA_DEVICE        "( default )"


/* Limits on values of CW send and timing parameters */
#define CW_SPEED_MIN             4   /* Lowest WPM allowed */
#define CW_SPEED_MAX            60   /* Highest WPM allowed */
#define CW_SPEED_STEP            1
#define CW_SPEED_INITIAL        12   /* Initial send speed in WPM */
#define CW_FREQUENCY_MIN         0   /* Lowest tone allowed (0=silent) */
#define CW_FREQUENCY_MAX      4000   /* Highest tone allowed */
#define CW_FREQUENCY_INITIAL   800   /* Initial tone in Hz */
#define CW_FREQUENCY_STEP       20
#define CW_VOLUME_MIN            0   /* Quietest volume allowed (0=silent) */
#define CW_VOLUME_MAX          100   /* Loudest volume allowed */
#define CW_VOLUME_INITIAL       70   /* Initial volume percent */
#define CW_VOLUME_STEP           1
#define CW_GAP_MIN               0   /* Lowest extra gap allowed */
#define CW_GAP_MAX              60   /* Highest extra gap allowed */
#define CW_GAP_INITIAL           0   /* Initial gap setting */
#define CW_GAP_STEP              1
#define CW_WEIGHTING_MIN        20   /* Lowest weighting allowed */
#define CW_WEIGHTING_MAX        80   /* Highest weighting allowed */
#define CW_WEIGHTING_INITIAL    50   /* Initial weighting setting */
#define CW_TOLERANCE_MIN         0   /* Lowest receive tolerance allowed */
#define CW_TOLERANCE_MAX        90   /* Highest receive tolerance allowed */
#define CW_TOLERANCE_INITIAL    50   /* Initial tolerance setting */
]]


ffi.cdef[[
enum cw_return_values {
	CW_FAILURE = 0,
	CW_SUCCESS = -1 };

/* supported audio sound systems */
enum cw_audio_systems {
	CW_AUDIO_NONE = 0,  /* initial value; this is not the same as CW_AUDIO_NULL */
	CW_AUDIO_NULL,      /* empty audio output (no sound, just timing); this is not the same as CW_AUDIO_NONE */
	CW_AUDIO_CONSOLE,   /* console buzzer */
	CW_AUDIO_OSS,
	CW_AUDIO_ALSA,
	CW_AUDIO_PA,        /* PulseAudio */
	CW_AUDIO_SOUNDCARD  /* OSS, ALSA or PulseAudio (PA) */
};

enum {
	CW_KEY_STATE_OPEN = 0,  /* key is open, no electrical contact in key, no sound */
	CW_KEY_STATE_CLOSED     /* key is closed, there is an electrical contact in key, a sound is generated */
};


typedef int16_t cw_sample_t;

enum { CW_DOT_REPRESENTATION = '.', CW_DASH_REPRESENTATION = '-' };

enum {
	CW_DEBUG_SILENT               = 1U << 0U,
	CW_DEBUG_KEYING               = 1U << 1U,
	CW_DEBUG_GENERATOR            = 1U << 2U,
	CW_DEBUG_TONE_QUEUE           = 1U << 3U,
	CW_DEBUG_PARAMETERS           = 1U << 4U,
	CW_DEBUG_RECEIVE_STATES       = 1U << 5U,
	CW_DEBUG_KEYER_STATES         = 1U << 6U,
	CW_DEBUG_STRAIGHT_KEY_STATES  = 1U << 7U,
	CW_DEBUG_LOOKUPS              = 1U << 8U,
	CW_DEBUG_FINALIZATION         = 1U << 9U,
	CW_DEBUG_STDLIB               = 1U << 10U,
	CW_DEBUG_SOUND_SYSTEM         = 1U << 11U,
	CW_DEBUG_INTERNAL             = 1U << 12U,
	CW_DEBUG_CLIENT_CODE          = 1U << 13U,
	CW_DEBUG_MASK                 = 0xffff
};

enum {
	CW_DEBUG_DEBUG   = 0,
	CW_DEBUG_INFO    = 1,
	CW_DEBUG_WARNING = 2,
	CW_DEBUG_ERROR   = 3,
	CW_DEBUG_NONE    = 4  
};

enum {
	CW_TONE_SLOPE_SHAPE_LINEAR, 
	CW_TONE_SLOPE_SHAPE_RAISED_COSINE,
	CW_TONE_SLOPE_SHAPE_SINE,
	CW_TONE_SLOPE_SHAPE_RECTANGULAR
};

typedef struct cw_gen_struct cw_gen_t;

       int cw_generator_new(int audio_system, const char *device);
       void cw_generator_delete(void);
       int cw_generator_start(void);
       void cw_generator_stop(void);
       int cw_set_send_speed(int new_value);
       int cw_set_frequency(int new_value);
       int cw_set_volume(int new_value);
       int cw_set_gap(int new_value);
       int cw_set_weighting(int new_value);
       int cw_get_send_speed(void);
       int cw_get_frequency(void);
       int cw_get_volume(void);
       int cw_get_gap(void);
       int cw_get_weighting(void);
       void cw_get_send_parameters(int *dot_usecs, int *dash_usecs,
                                   int *end_of_element_usecs,
                                   int *end_of_character_usecs, int *end_of_word_usecs,
                                   int *additional_usecs, int *adjustment_usecs);
       int cw_send_dot(void);
       int cw_send_dash(void);
       int cw_send_character_space(void);
       int cw_send_word_space(void);
       int cw_send_representation(const char *representation);
       int cw_send_representation_partial(const char *representation);
       int cw_send_character(char c);
       int cw_send_character_partial(char c);
       int cw_send_string(const char *string);
       void cw_reset_send_receive_parameters(void);
       const char *cw_get_console_device(void);
       const char *cw_get_soundcard_device(void);
       const char *cw_generator_get_audio_system_label(void);
       int cw_generator_remove_last_character(void);
       int  cw_register_tone_queue_low_callback(void (*callback_func)(void*), void *callback_arg, int level);
       bool cw_is_tone_busy(void);
       int cw_wait_for_tone(void);
       int cw_wait_for_tone_queue(void);
       int cw_wait_for_tone_queue_critical(int level);
       bool cw_is_tone_queue_full(void);
       int cw_get_tone_queue_capacity(void);
       int cw_get_tone_queue_length(void);
       void cw_flush_tone_queue(void);
       void cw_reset_tone_queue(void);
       int cw_queue_tone(int usecs, int frequency);
       int cw_set_receive_speed(int new_value);
       int cw_get_receive_speed(void);
       int cw_set_tolerance(int new_value);
       int cw_get_tolerance(void);
       void cw_get_receive_parameters(int *dot_usecs, int *dash_usecs,
                                      int *dot_min_usecs, int *dot_max_usecs,
                                      int *dash_min_usecs, int *dash_max_usecs,
                                      int *end_of_element_min_usecs,
                                      int *end_of_element_max_usecs,
                                      int *end_of_element_ideal_usecs,
                                      int *end_of_character_min_usecs,
                                      int *end_of_character_max_usecs,
                                      int *end_of_character_ideal_usecs,
                                      int *adaptive_threshold);
       int cw_set_noise_spike_threshold(int new_value);
       int cw_get_noise_spike_threshold(void);
       void cw_get_receive_statistics(double *dot_sd, double *dash_sd,
                                      double *element_end_sd, double *character_end_sd);
       void cw_reset_receive_statistics(void);
       void cw_enable_adaptive_receive(void);
       void cw_disable_adaptive_receive(void);
       bool cw_get_adaptive_receive_state(void);
       int cw_start_receive_tone(const struct timeval *timestamp);
       int cw_end_receive_tone(const struct timeval *timestamp);
       int cw_receive_buffer_dot(const struct timeval *timestamp);
       int cw_receive_buffer_dash(const struct timeval *timestamp);
       int cw_receive_representation(const struct timeval *timestamp,
                                     /* out */ char *representation,
                                     /* out */ bool *is_end_of_word,
                                     /* out */ bool *is_error);
       int cw_receive_character(const struct timeval *timestamp,
                                /* out */ char *c,
                                /* out */ bool *is_end_of_word,
                                /* out */ bool *is_error);
       void cw_clear_receive_buffer(void);
       int cw_get_receive_buffer_capacity(void);
       int cw_get_receive_buffer_length(void);
       void cw_reset_receive(void);
       void cw_register_keying_callback(void (*callback_func)(void*,  int),  void  *callback_arg);
       void cw_enable_iambic_curtis_mode_b(void);
       void cw_disable_iambic_curtis_mode_b(void);
       int cw_get_iambic_curtis_mode_b_state(void);
       int cw_notify_keyer_paddle_event(int dot_paddle_state, int dash_paddle_state);
       int cw_notify_keyer_dot_paddle_event(int dot_paddle_state);
       int cw_notify_keyer_dash_paddle_event(int dash_paddle_state);
       void cw_get_keyer_paddles(int *dot_paddle_state, int *dash_paddle_state);
       void   cw_get_keyer_paddle_latches(int   *dot_paddle_latch_state,  int  *dash_paddle_latch_state);
       bool cw_is_keyer_busy(void);
       int cw_wait_for_keyer_element(void);
       int cw_wait_for_keyer(void);
       void cw_reset_keyer(void);
       int cw_notify_straight_key_event(int key_state);
       int cw_get_straight_key_state(void);
       bool cw_is_straight_key_busy(void);
       void cw_reset_straight_key(void);
       bool cw_is_alsa_possible(const char * device_name);
       bool cw_is_console_possible(const char * device_name);
       int cw_get_character_count(void);
       void cw_list_characters(char * list);
       int cw_get_maximum_representation_length(void);
       int cw_lookup_character(char character, char * representation);
       char * cw_character_to_representation(int character);
       int cw_check_representation(const char * representation);
       bool cw_representation_is_valid(const char * representation);
       int cw_lookup_representation(const char * representation, char * character);
       int cw_representation_to_character(const char * representation);
       int cw_get_procedural_character_count(void);
       void cw_list_procedural_characters(char * list);
       int cw_get_maximum_procedural_expansion_length(void);
       int cw_lookup_procedural_character(char character, char *expansion, int *  is_usually_expanded);
       int cw_get_maximum_phonetic_length(void);
       int cw_lookup_phonetic(char character, char * phonetic);
       bool cw_character_is_valid(char character);
       int cw_check_character(char character);
       bool cw_string_is_valid(const char * string);
       int cw_check_string(const char * string);
//       void cw_set_debug_flags(uint32_t flags);
//       void cw_debug_set_flags(cw_debug_t * debug_object, uint32_t flags);
//       uint32_t cw_get_debug_flags(void);
//       uint32_t cw_debug_get_flags(const cw_debug_t * debug_object);
//       bool cw_debug_has_flag(const cw_debug_t * debug_object, uint32_t flag);
       int  cw_generator_set_tone_slope(cw_gen_t  * gen, int slope_shape, int slope_duration);
       bool cw_is_null_possible(__attribute__((unused)) const char * device_name);
       bool cw_is_oss_possible(const char * device_name);
       bool cw_is_pa_possible(const char * device_name);
       void cw_block_callback(int block);
       int cw_register_signal_handler(int signal_number, void (*callback_func)(int));
       int cw_unregister_signal_handler(int signal_number);
       int cw_version(void);
       void cw_license(void);
       const char * cw_get_audio_system_label(int sound_system);
       void cw_get_speed_limits(int * min_speed, int * max_speed);
       void cw_get_frequency_limits(int * min_frequency, int * max_frequency);
       void cw_get_volume_limits(int * min_volume, int * max_volume);
       void cw_get_gap_limits(int * min_gap, int * max_gap);
       void cw_get_tolerance_limits(int * min_tolerance, int * max_tolerance);
       void cw_get_weighting_limits(int * min_weighting, int * max_weighting);
       void cw_complete_reset(void);
]]
local cw = ffi.load("cw")
return cw


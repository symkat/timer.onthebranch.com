<template>
    <div class="container">
        <div style="margin-top: 4em"></div>
        
        <!-- Episode Record Start / Stop Buttons -->
        <div class="container has-text-centered" style="margin-bottom: 2em">
            <button class="button is-medium is-link"                     v-if="! is_recording" :disabled="! is_global_timer_running"        v-on:click="startEpisodeRecording()">Record Episode</button>
            <button class="button is-medium is-danger has-text-centered" v-if="is_recording"   :disabled="is_paused || want_delete_episode" v-on:click="stopEpisodeRecording()" >Complete Episode</button>
        </div>

        <!-- Timer Display -->
        <div class="container has-text-centered" style="margin-bottom: 2em">
            <span class="is-size-1" id="time" v-html="time"></span>
        </div>
        
        <!-- Control Buttons For Episode Timer -->
        <div class="container has-text-centered" style="margin-bottom: 2em">
            <button class="button ctl-btn is-medium is-info"    v-on:click="sendFlag()"      :disabled="is_paused || want_delete_episode || ! is_recording" ><i class="fas fa-flag"></i></button>
            <button class="button ctl-btn is-medium is-info"    v-on:click="promptComment()" :disabled="is_paused || want_delete_episode || ! is_recording" ><i class="fas fa-comment"></i></button>

            <button class="button ctl-btn is-medium is-info"    v-on:click="sendPause()"     :disabled="! is_recording || want_delete_episode"  v-if="! is_paused" ><i class="fas fa-pause"></i></button>
            <button class="button ctl-btn is-medium is-warning" v-on:click="sendPlay()"                                  v-if="is_paused"   ><i class="fas fa-play"></i></button>

            <button class="button ctl-btn is-medium is-danger" v-on:click="removeEpisode()"  :disabled="! is_recording || is_paused"><i class="fas fa-ban"></i></button>
        </div>

        <!-- Comment Section -->
        <div class="container" v-if="want_comment" style="margin-bottom: 2em">
            <input type="text" ref='comment_content' v-model="comment_content" autofocus=true class="input" placeholder="Enter Comment" v-on:keyup.enter="submitComment()" />
        </div>
        
        <!-- Delete Confirmation -->
        <div class="container" v-if="want_delete_episode" style="margin-bottom: 2em">
            <input type="text" ref='delete_episode' v-model="delete_episode" autofocus=true class="input" placeholder="Type 'delete' to delete. Enter will cancel." v-on:keyup.enter="submitEpisodeDelete()" />
        </div>
        
    </div>
</template>

<style>
    .ctl-btn {
        margin-right: 0.5em;
        margin-left: 0.5em;
    }
    
</style>

<script>
    
    import { EventBus } from './EventBus.js';

    export default {
        data: function() {
            return {
                state: "paused",
                startTime: Date.now(),
                currentTime: Date.now(),
                interval: null,
                is_paused: false,
                is_recording: false,
                episode_number: 1,
                want_delete_episode: false,
                want_comment: false,
                comment_time: null,
                comment_content: null,
                delete_episode: null,
                is_global_timer_running: false,
                pause_time: null
            }
        },
        mounted: function() {

            this.interval = setInterval(this.updateCurrentTime, 1000);
            
            EventBus.$on('GlobalSessionRecordingState', value => {
                this.$data.is_global_timer_running = value;
            });

            EventBus.$on('EpisodeRecordingState', value => {
                this.$data.is_recording = value;
            });

        },
        destroyed: function() {
            clearInterval(this.interval)
        },
        computed: {
            episode_name: function () {
                return 'Episode ' + ( this.$data.episode_number >= 10 ? this.$data.episode_number : '0' + this.$data.episode_number.toString() );
            },
            time: function() {
                return this.hours + ':' + this.minutes + ':' + this.seconds;
            },
            milliseconds: function() {
                return this.currentTime - this.$data.startTime;
            },
            hours: function() {
                var lapsed = this.milliseconds;
                var hrs = Math.floor((lapsed / 1000 / 60 / 60));
                return hrs >= 10 ? hrs : '0' + hrs;
            },
            minutes: function() {
                var lapsed = this.milliseconds;
                var min = Math.floor((lapsed / 1000 / 60) % 60);
                return min >= 10 ? min : '0' + min;
            },
            seconds: function() {
                var lapsed = this.milliseconds;
                var sec = Math.ceil((lapsed / 1000) % 60);
                return sec >= 10 ? sec : '0' + sec;
            },
            ms: function() {
                return this.milliseconds.toString().substr(-3,1);
            }
            
        },
        methods: {
            startEpisodeRecording: function () {
                this.reset();
                EventBus.$emit('EpisodeRecordingState', true );
                EventBus.$emit('episodeNameChange', this.episode_name);
                EventBus.$emit('addNote', { content: 'BEGIN EPISODE', episodeSessionTimer: '00:00:00' } );
            },
            stopEpisodeRecording: function() {
                this.pause();
                this.$data.episode_number += 1;
                EventBus.$emit('EpisodeRecordingState', false );
                EventBus.$emit('addNote', 'END EPISODE' );
                EventBus.$emit('EpisodeRecordingState', false );
            },
            submitComment: function () {
                EventBus.$emit('addNote', { content: this.$data.comment_content, episodeSessionTimer: this.$data.comment_time } );
                this.$data.want_comment = false;
                this.$data.comment_content = null;
                this.$data.comment_time = null;
            },
            submitEpisodeDelete: function () {
                if ( this.$data.delete_episode === 'delete' ) {
                    this.reset();
                    this.pause();
                    EventBus.$emit('deleteEpisodeFromLog', this.episode_name );
                    EventBus.$emit('EpisodeRecordingState', false );
                } 
                this.$data.want_delete_episode = false;
                this.$data.delete_episode = null;
            },
            removeEpisode: function () {
                this.$data.want_delete_episode = true;
                this.$nextTick( () => this.$refs.delete_episode.focus() );
            },
            
            reset: function() {
                this.$data.state = "started";
                this.$data.startTime = Date.now();
                this.$data.currentTime = Date.now();
            },
            pause: function() {
                this.$data.state = "paused";
            },
            resume: function() {
                this.$data.state = "started";
            },
            updateCurrentTime: function() {
                if (this.$data.state === "started") {
                    this.currentTime = Date.now();
                    EventBus.$emit('episodeTimeChange', this.time );
                }
            },
            finishRecording: function() {
                this.$data.is_recording = false;
                EventBus.$emit('addNote', 'Finished recording episode ' + this.$data.episode_name );
                EventBus.$emit('episodeTimeChange', null );
                this.pause();
            },
            sendFlag: function() {
                EventBus.$emit('addNote', "FLAG" );
            },
            sendPause: function() {
                this.$data.is_paused = true;
                this.$data.state = "paused";
                this.$data.pause_time = Date.now();
                EventBus.$emit('addNote', 'PAUSE EPISODE' );
            },
            sendPlay: function() {
                this.$data.is_paused = false;
                EventBus.$emit('addNote', 'RESUME EPISODE' );
                this.$data.startTime += ( Date.now() - this.$data.pause_time );
                this.$data.state = "started";
            },
            promptComment: function() {
                this.$data.comment_time = this.time;
                this.$data.want_comment = true;
                this.$nextTick( () => this.$refs.comment_content.focus() );
            },
        }
    } 
</script>

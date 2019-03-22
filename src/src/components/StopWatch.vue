<template>
    <div class="container level">
        <div class="level-item">
            <button v-if="$data.state === 'paused'"  class="button is-large is-link" v-on:click="startGlobalSession()">Begin Recording Session</button>
            <button v-if="$data.state === 'started'" :disabled="is_episode_timer_running" class="button is-large is-danger" v-on:click="stopGlobalSession()">Stop Recording Session</button>
        </div>
        <div class="level-item">
            <h1 class="title is-size-1">Happy Birthday!</h1>
        </div>
        <div class="level-item">
            <span class="is-size-1" id="time" v-html="time"></span>
        </div>
    </div>
</template>

<style>
    
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
                is_episode_timer_running: false
            }
        },
        mounted: function() {
            this.interval = setInterval(this.updateCurrentTime, 100);
            EventBus.$on('EpisodeRecordingState', value => {
                this.$data.is_episode_timer_running = value;
            });
        },
        destroyed: function() {
            clearInterval(this.interval)
        },
        computed: {
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
            }
        },
        methods: {
            startGlobalSession: function () {
                this.reset();
                EventBus.$emit('addNote', 'Global Session Has Started' );
                EventBus.$emit('GlobalSessionRecordingState', true );
            },
            stopGlobalSession: function () {
                this.pause();
                EventBus.$emit('addNote', 'Global Session Has Stopped' );
                EventBus.$emit('GlobalSessionRecordingState', false );
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
                if (this.$data.state == "started") {
                    this.currentTime = Date.now();
                    EventBus.$emit('globalTimeChange', this.time );
                }
            }
        }
    } 
</script>

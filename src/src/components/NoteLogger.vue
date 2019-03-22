<template>
    <div class="container">
        <div class="box is-family-monospace">
            <ul>
                <li v-bind:key=item.index v-for="item in items"> {{item.date }} {{ item.globalSessionTimer || 'xx:xx:xx' }} {{ item.episodeSessionTimer || 'xx.xx.xx' }} {{ item.episode || 'Episode --' }} : {{ item.note }}</li>
            </ul>
        </div>
    </div>
</template>

<script>
    import { EventBus } from './EventBus.js';

    export default {
        name: 'NoteLogger',
        mounted: function() {
            EventBus.$on('addNote', note => {
                this.addNote(note);
            });
            EventBus.$on('deleteEpisodeFromLog', episode_name => {
                this.deleteEpisodeFromLog( episode_name );
            });
            EventBus.$on('globalTimeChange', time => {
                this.$data.currentGlobalSessionTimer = time;
            });
            EventBus.$on('episodeTimeChange', time => {
                this.$data.currentEpisodeSessionTimer = time;
            });
            EventBus.$on('episodeNameChange', name => {
                this.$data.currentEpisodeName = name;
            });
        },
        data: function() {
            return {
                items: [ { date: this.getDate(), note : 'Log Started' } ],
                currentGlobalSessionTimer: false,
                currentEpisodeName: null,
            }
        },
        methods: {
            addNote: function(note) {
                var index = 1;
                if ( this.$data.items.length >= 1 ) {
                    index = this.$data.items[this.$data.items.length - 1].index;
                }

                if ( typeof(note) === 'string' ) {
                    this.$data.items.push({ 
                        index:               index,
                        episode:             this.$data.currentEpisodeName,
                        date:                this.getDate(), 
                        globalSessionTimer:  this.$data.currentGlobalSessionTimer, 
                        episodeSessionTimer: this.$data.currentEpisodeSessionTimer, 
                        note:                note 
                    });
                } else {
                    this.$data.items.push({ 
                        index:               index,
                        date:                this.getDate(), 
                        episode:             this.$data.currentEpisodeName,
                        globalSessionTimer:  this.$data.currentGlobalSessionTimer, 
                        episodeSessionTimer: note.episodeSessionTimer ? note.episodeSessionTimer : this.$data.currentEpisodeSessionTimer, 
                        note:                note.content
                    });
                }
            },
            deleteEpisodeFromLog: function (episode_name) {
                for (var i = this.$data.items.length - 1; i >= 0 ; i-- ) {
                    if ( this.$data.items[i].episode === episode_name ) {
                        this.$data.items.splice(i, 1);
                    }
                }
            },
            getDate: function () {
                var dateObj = new Date;
                return (
                    ( '0' + (dateObj.getMonth() + 1) ).slice(-2)) + "/" + 
                    ( '0' + dateObj.getDate()).slice(-2)          + "/" +  
                    ( dateObj.getYear() + 1900 )                  + " " + 
                    ( '0' + dateObj.getHours()).slice(-2)         + ":" + 
                    ( '0' + dateObj.getMinutes()).slice(-2)       + ":" + 
                    ( '0' + dateObj.getSeconds()).slice(-2)       + "." + 
                    ( '00' + dateObj.getMilliseconds()).slice(-3)
            }
        }
    }
</script>

<style>
</style>

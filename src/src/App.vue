<template>
    <div id="app">
        <section class="hero is-primary">
            <div class="hero-body">
                <SessionTimer NoteLogger=NoteLogger />
            </div>
        </section>

        <EpisodeTimer  />

        <NoteLogger />

    </div>
</template>

<script>
    import SessionTimer from './components/StopWatch.vue'
    import EpisodeTimer from './components/EpisodeTimer.vue'
    import NoteLogger   from './components/NoteLogger.vue'

    export default {
        name: 'app',
        components: {
            SessionTimer,
            EpisodeTimer,
            NoteLogger
        }
    }
</script>

<style lang="scss">
    @import '../node_modules/bulma/bulma.sass';
</style>


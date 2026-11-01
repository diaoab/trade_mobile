import { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { Button, ErrorText, Field, GUTTER, Row, Section } from '@/components/ui';
import { useAuth } from '@/lib/auth';
import { useColors } from '@/lib/theme';

export function ChangePassword() {
  const colors = useColors();
  const { changePassword } = useAuth();
  const [open, setOpen] = useState(false);
  const [current, setCurrent] = useState('');
  const [next, setNext] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const [busy, setBusy] = useState(false);

  async function submit() {
    setBusy(true);
    setError(null);
    try {
      await changePassword(current, next);
      setCurrent('');
      setNext('');
      setOpen(false);
      setDone(true);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Section title="Mot de passe">
      {!open ? (
        <Row
          last
          onPress={() => {
            setOpen(true);
            setDone(false);
          }}>
          <Text style={[styles.label, { color: colors.text }]}>
            {done ? 'Mot de passe modifié ✓' : 'Changer le mot de passe'}
          </Text>
        </Row>
      ) : (
        <View style={styles.form}>
          <Field
            label="Mot de passe actuel"
            value={current}
            onChangeText={setCurrent}
            secureTextEntry
            autoComplete="current-password"
            textContentType="password"
          />
          <Field
            label="Nouveau mot de passe"
            value={next}
            onChangeText={setNext}
            secureTextEntry
            autoComplete="new-password"
            textContentType="newPassword"
            placeholder="8 caractères minimum"
            onSubmitEditing={submit}
          />
          <ErrorText message={error} />
          <Text style={[styles.hint, { color: colors.secondary }]}>
            Les autres appareils connectés seront déconnectés.
          </Text>
          <Button title="Enregistrer" onPress={submit} loading={busy} disabled={!current || !next} />
        </View>
      )}
    </Section>
  );
}

const styles = StyleSheet.create({
  label: { fontSize: 16, flex: 1 },
  hint: { fontSize: 13, lineHeight: 18 },
  form: { paddingHorizontal: GUTTER, paddingVertical: 14, gap: 14 },
});

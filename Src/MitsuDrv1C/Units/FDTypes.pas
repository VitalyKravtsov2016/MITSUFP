unit FDTypes;

interface

const
  /// //////////////////////////////////////////////////////////////////////////
  // �������������� ��
  // FD notification flags

  FD_NF_3_DAY_LEFT = 0; // ������� ������ �� (�� ��������� ����� �������� 3 ���)
  FD_NF_30_DAYS_LEFT = 1;
  // ���������� ������� �� (�� ��������� ����� �������� 30 ����)
  FD_NF_ALMOST_FULL = 2; // ������������ ������ �� (����� �� �������� �� 99 %)
  FD_NF_FDO_TIMEOUT = 3; // ��������� ����� �������� ������ ���
  FD_NF_FLC_FAILED = 4; // ����� �� ������ ������������������� ��������
  FD_NF_CONFIG_NEEDED = 5; // ��������� ��������� ���
  FD_NF_FDO_ANNULATED = 6; // ��� �����������

implementation

end.
